import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Temporary Firebase configuration placeholder.
/// Replace this file by running `flutterfire configure` once the
/// corresponding Firebase project is ready.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _webOptions;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidOptions;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _appleOptions;
      default:
        throw UnsupportedError(
          'Firebase options are not configured for $defaultTargetPlatform.',
        );
    }
  }

  static final FirebaseOptions _webOptions = FirebaseOptions(
    apiKey: 'AIzaSyAFzyKdqN8_1MCVG4NuL6KtYrr2fZ4lDqY',
    appId: '1:97156095733:web:ef20069753b44487e72fbc',
    messagingSenderId: '97156095733',
    projectId: 'pausalac-3c82e',
    authDomain: 'pausalac-3c82e.firebaseapp.com',
    storageBucket: 'pausalac-3c82e.firebasestorage.app',
    measurementId: 'G-6ZVR0Y3D1N',
  );

  static final FirebaseOptions _androidOptions = FirebaseOptions(
  apiKey: 'AIzaSyAFzyKdqN8_1MCVG4NuL6KtYrr2fZ4lDqY',
    appId: '1:97156095733:web:ef20069753b44487e72fbc',
    messagingSenderId: '97156095733',
    projectId: 'pausalac-3c82e',
  storageBucket: 'pausalac-3c82e.firebasestorage.app'
  );

  static final FirebaseOptions _appleOptions = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
  );
}
