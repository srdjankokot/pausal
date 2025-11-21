import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleUser {
  const GoogleUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
}

class GoogleAuthService {
  GoogleAuthService({String? webClientId})
      : _googleSignIn = GoogleSignIn(
          clientId: webClientId,
          scopes: _scopes,
          signInOption: SignInOption.standard,
          hostedDomain: null,
        );

  static const List<String> _scopes = <String>[
    sheets.SheetsApi.spreadsheetsScope,
    'https://www.googleapis.com/auth/drive.file',
    'openid',
    'email'
  ];
  static const Duration _tokenLeeway = Duration(seconds: 30);
  static const Duration _assumedTokenLifetime = Duration(minutes: 55);

  static const String _userIdKey = 'google.auth.user.id';
  static const String _userEmailKey = 'google.auth.user.email';
  static const String _userNameKey = 'google.auth.user.name';
  static const String _userPhotoKey = 'google.auth.user.photo';
  static const String _tokenKey = 'google.auth.accessToken';
  static const String _expiryKey = 'google.auth.accessTokenExpiry';
  static const String _logoutFlagKey = 'google.auth.explicitLogout';

  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentAccount;
  GoogleUser? _cachedUser;
  auth.AccessCredentials? _cachedCredentials;
  auth.AuthClient? _currentClient;

  Future<GoogleUser?> signIn() async {
    final account = await _googleSignIn.signIn();
    return _handleAccount(account);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // ignore - disconnect is not supported on all platforms
    }
    await _googleSignIn.signOut();
    _currentAccount = null;
    _cachedUser = null;
    _cachedCredentials = null;
    _currentClient?.close();
    _currentClient = null;
    await _clearPersistedSession();
    await _setLogoutFlag(true);
  }

  Future<GoogleUser?> restorePersistedUser() async {
    return _restorePersistedSession();
  }

  Future<auth.AuthClient?> getAuthenticatedClient() async {
    final now = DateTime.now().toUtc();

    if (_cachedCredentials != null &&
        _cachedCredentials!.accessToken.expiry.isAfter(now.add(_tokenLeeway))) {
      return _ensureClient(_cachedCredentials!);
    }

    final GoogleSignInAccount? account = _currentAccount;
    if (account != null) {
      final credentials = await _refreshCredentials(account);
      if (credentials != null) {
        return _ensureClient(credentials, forceReplace: true);
      }
    }

    await _restorePersistedSession();
    if (_cachedCredentials != null &&
        _cachedCredentials!.accessToken.expiry.isAfter(now.add(_tokenLeeway))) {
      return _ensureClient(_cachedCredentials!);
    }

    return null;
  }

  Future<String?> getActiveAccessToken() async {
    final now = DateTime.now().toUtc();
    if (_cachedCredentials != null &&
        _cachedCredentials!.accessToken.expiry.isAfter(now.add(_tokenLeeway))) {
      return _cachedCredentials!.accessToken.data;
    }
    final authClient = await getAuthenticatedClient();
    if (authClient == null) {
      return null;
    }
    return _cachedCredentials?.accessToken.data;
  }

  Future<GoogleUser?> _handleAccount(
    GoogleSignInAccount? account,
  ) async {
    _currentAccount = account;
    if (account == null) {
      _cachedUser = null;
      _cachedCredentials = null;
      _currentClient?.close();
      _currentClient = null;
      await _clearPersistedSession();
      return null;
    }

    final user = GoogleUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
    _cachedUser = user;

    try {
      final credentials = await _fetchCredentials(account);
      _cachedCredentials = credentials;
      await _persistSession(user, credentials);
    } catch (_) {
      await _persistSession(user, null);
    }

    return user;
  }

  Future<auth.AccessCredentials?> _refreshCredentials(
    GoogleSignInAccount account,
  ) async {
    try {
      final credentials = await _fetchCredentials(account);
      if (credentials != null) {
        _cachedCredentials = credentials;
        if (_cachedUser != null) {
          await _persistSession(_cachedUser!, credentials);
        }
      }
      return credentials;
    } catch (_) {
      return null;
    }
  }

  Future<auth.AccessCredentials?> _fetchCredentials(
    GoogleSignInAccount account,
  ) async {
    String? accessToken;
    try {
      final authData = await account.authentication;
      accessToken = authData.accessToken;
    } catch (_) {
      accessToken = null;
    }

    if (accessToken == null || accessToken.isEmpty) {
      try {
        final headers = await account.authHeaders;
        final authorizationHeader =
            headers['Authorization'] ?? headers['authorization'];
        if (authorizationHeader != null) {
          // google_sign_in_web can expose the token only via authHeaders.
          const bearerPrefix = 'Bearer ';
          if (authorizationHeader.startsWith(bearerPrefix)) {
            accessToken = authorizationHeader.substring(bearerPrefix.length);
          } else if (authorizationHeader.toLowerCase().startsWith('bearer ')) {
            accessToken = authorizationHeader.substring('bearer '.length);
          }
        }
      } catch (_) {
        accessToken = null;
      }
    }

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    final expiry = DateTime.now().toUtc().add(_assumedTokenLifetime);
    return auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken, expiry),
      null,
      _scopes,
    );
  }

  Future<GoogleUser?> _restorePersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedOut = prefs.getBool(_logoutFlagKey) ?? false;
    // _explicitLogoutFlag = isLoggedOut;
    if (isLoggedOut) {
      _cachedUser = null;
      _cachedCredentials = null;
      return null;
    }
    final id = prefs.getString(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    if (id == null || email == null) {
      return null;
    }

    final user = GoogleUser(
      id: id,
      email: email,
      displayName: prefs.getString(_userNameKey),
      photoUrl: prefs.getString(_userPhotoKey),
    );
    _cachedUser = user;

    final accessToken = prefs.getString(_tokenKey);
    final expiryMillis = prefs.getInt(_expiryKey);
    if (accessToken != null && expiryMillis != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        expiryMillis,
        isUtc: true,
      );
      if (expiry.isAfter(DateTime.now().toUtc().add(_tokenLeeway))) {
        _cachedCredentials = auth.AccessCredentials(
          auth.AccessToken('Bearer', accessToken, expiry),
          null,
          _scopes,
        );
      } else {
        _cachedCredentials = null;
        await prefs.remove(_tokenKey);
        await prefs.remove(_expiryKey);
      }
    } else {
      _cachedCredentials = null;
    }

    return user;
  }

  Future<void> _persistSession(
    GoogleUser user,
    auth.AccessCredentials? credentials,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userEmailKey, user.email);
    if (user.displayName != null) {
      await prefs.setString(_userNameKey, user.displayName!);
    } else {
      await prefs.remove(_userNameKey);
    }
    if (user.photoUrl != null) {
      await prefs.setString(_userPhotoKey, user.photoUrl!);
    } else {
      await prefs.remove(_userPhotoKey);
    }

    if (credentials != null) {
      await prefs.setString(_tokenKey, credentials.accessToken.data);
      await prefs.setInt(
        _expiryKey,
        credentials.accessToken.expiry.toUtc().millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove(_tokenKey);
      await prefs.remove(_expiryKey);
    }
    await _setLogoutFlag(false);
  }

  Future<void> _clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhotoKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
  }

  Future<void> _setLogoutFlag(bool value) async {
    // _explicitLogoutFlag = value;
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_logoutFlagKey, true);
    } else {
      await prefs.remove(_logoutFlagKey);
    }
  }

  auth.AuthClient? _ensureClient(
    auth.AccessCredentials credentials, {
    bool forceReplace = false,
  }) {
    if (!forceReplace && _currentClient != null) {
      return _currentClient;
    }
    _currentClient?.close();
    final baseClient = http.Client();
    _currentClient = auth.authenticatedClient(baseClient, credentials);
    return _currentClient;
  }
}
