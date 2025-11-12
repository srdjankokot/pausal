import 'package:shared_preferences/shared_preferences.dart';

class SyncMetadataStorage {
  static const _spreadsheetIdKey = 'sheet.spreadsheetId';
  static const _expensesSheetKey = 'sheet.expenses';
  static const _clientsSheetKey = 'sheet.clients';
  static const _profileSheetKey = 'sheet.profile';

  static Future<void> save({
    required String spreadsheetId,
    required String expensesSheet,
    required String clientsSheet,
    required String profileSheet,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spreadsheetIdKey, spreadsheetId);
    await prefs.setString(_expensesSheetKey, expensesSheet);
    await prefs.setString(_clientsSheetKey, clientsSheet);
    await prefs.setString(_profileSheetKey, profileSheet);
  }

  static Future<SyncMetadata?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final spreadsheetId = prefs.getString(_spreadsheetIdKey);
    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      return null;
    }
    final expensesSheet = prefs.getString(_expensesSheetKey) ?? 'Expenses';
    final clientsSheet = prefs.getString(_clientsSheetKey) ?? 'Clients';
    final profileSheet = prefs.getString(_profileSheetKey) ?? 'Profile';
    return SyncMetadata(
      spreadsheetId: spreadsheetId,
      expensesSheet: expensesSheet,
      clientsSheet: clientsSheet,
      profileSheet: profileSheet,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spreadsheetIdKey);
    await prefs.remove(_expensesSheetKey);
    await prefs.remove(_clientsSheetKey);
    await prefs.remove(_profileSheetKey);
  }
}

class SyncMetadata {
  SyncMetadata({
    required this.spreadsheetId,
    required this.expensesSheet,
    required this.clientsSheet,
    required this.profileSheet,
  });

  final String spreadsheetId;
  final String expensesSheet;
  final String clientsSheet;
  final String profileSheet;
}
