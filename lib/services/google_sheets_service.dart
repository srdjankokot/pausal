import 'dart:async';
import 'dart:convert';

import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class GoogleSheetsService {
  GoogleSheetsService({
    required auth.AuthClient client,
    required String spreadsheetId,
    this.expensesSheet = 'Expenses',
    this.clientsSheet = 'Clients',
    this.profileSheet = 'Profile',
  })  : _client = client,
        _spreadsheetId = spreadsheetId,
        _api = sheets.SheetsApi(client);

  final auth.AuthClient _client;
  final sheets.SheetsApi _api;
  final String _spreadsheetId;
  final String expensesSheet;
  final String clientsSheet;
  final String profileSheet;

  static Future<String> createSpreadsheet({
    required auth.AuthClient client,
    required String title,
    required String expensesSheet,
    required String clientsSheet,
    required String profileSheet,
  }) async {
    final api = sheets.SheetsApi(client);
    final request = sheets.Spreadsheet(
      properties: sheets.SpreadsheetProperties(title: title),
      sheets: [
        sheets.Sheet(properties: sheets.SheetProperties(title: expensesSheet)),
        sheets.Sheet(properties: sheets.SheetProperties(title: clientsSheet)),
        sheets.Sheet(properties: sheets.SheetProperties(title: profileSheet)),
      ],
    );

    final response = await api.spreadsheets.create(request);
    final spreadsheetId = response.spreadsheetId;
    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      throw StateError('Neuspešno kreiranje Google Sheet dokumenta.');
    }
    return spreadsheetId;
  }

  Future<void> ensureStructure() async {
    await _ensureSheet(expensesSheet, [
      'ID',
      'Tip',
      'Naziv',
      'Iznos',
      'Datum',
      'Broj fakture',
      'Napomena',
      'Klijent ID',
      'Stavke',
    ]);
    await _ensureSheet(
      clientsSheet,
      ['ID', 'Naziv', 'PIB', 'Adresa'],
    );
    await _ensureSheet(
      profileSheet,
      ['Sekcija', 'Polje', 'Vrednost'],
    );
  }

  Future<void> uploadAll({
    required List<Map<String, dynamic>> entries,
    required List<Map<String, dynamic>> clients,
    required Map<String, dynamic> companyProfile,
    required Map<String, dynamic> taxProfile,
  }) async {
    await ensureStructure();

    final expensesValues = entries.map((entry) {
      final items = entry['items'] as List<dynamic>? ?? const [];
      final itemsJson = jsonEncode(items);
      return [
        entry['id'] ?? '',
        entry['kind'] ?? '',
        entry['title'] ?? '',
        entry['amount'] ?? 0,
        entry['date'] ?? '',
        entry['invoiceNumber'] ?? '',
        entry['note'] ?? '',
        entry['clientId'] ?? '',
        itemsJson,
      ];
    }).toList();

    final clientsValues = clients.map((client) {
      return [
        client['id'] ?? '',
        client['name'] ?? '',
        client['pib'] ?? '',
        client['address'] ?? '',
      ];
    }).toList();

    final profileValues = <List<dynamic>>[];
    companyProfile.forEach((key, value) {
      profileValues.add(['company', key, value ?? '']);
    });
    taxProfile.forEach((key, value) {
      profileValues.add(['tax', key, value ?? '']);
    });

    await _clearSheet(expensesSheet);
    await _clearSheet(clientsSheet);
    await _clearSheet(profileSheet);

    await _writeRange(expensesSheet, expensesValues);

    await _writeRange(clientsSheet, clientsValues);

    await _writeRange(profileSheet, profileValues);
  }

  Future<void> appendEntry(Map<String, dynamic> entry) async {
    await _api.spreadsheets.values.append(
      sheets.ValueRange(
        values: [
          [
            entry['id'] ?? '',
            entry['kind'] ?? '',
            entry['title'] ?? '',
            entry['amount'] ?? 0,
            entry['date'] ?? '',
            entry['invoiceNumber'] ?? '',
            entry['note'] ?? '',
            entry['clientId'] ?? '',
            jsonEncode(entry['items'] ?? const []),
          ],
        ],
      ),
      _spreadsheetId,
      '$expensesSheet!A2',
      valueInputOption: 'RAW',
    );
  }

  Future<void> appendClient(Map<String, dynamic> client) async {
    await _api.spreadsheets.values.append(
      sheets.ValueRange(
        values: [
          [
            client['id'] ?? '',
            client['name'] ?? '',
            client['pib'] ?? '',
            client['address'] ?? '',
          ],
        ],
      ),
      _spreadsheetId,
      '$clientsSheet!A2',
      valueInputOption: 'RAW',
    );
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    final response = await _api.spreadsheets.values.get(
      _spreadsheetId,
      '$expensesSheet!A2:I',
    );

    final values = response.values ?? [];
    return values.where((row) => row.isNotEmpty).map((row) {
      final cells = List<String>.generate(
        9,
        (index) => index < row.length ? row[index]?.toString() ?? '' : '',
      );
      List<dynamic> items = const [];
      if (cells[8].isNotEmpty) {
        try {
          final decoded = jsonDecode(cells[8]);
          if (decoded is List) {
            items = decoded;
          }
        } catch (_) {
          items = const [];
        }
      }
      return {
        'id': cells[0],
        'kind': cells[1],
        'title': cells[2],
        'amount': double.tryParse(cells[3]) ?? 0,
        'date': cells[4].isEmpty ? DateTime.now().toIso8601String() : cells[4],
        'invoiceNumber': cells[5],
        'note': cells[6],
        'clientId': cells[7],
        'items': items,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchClients() async {
    final response = await _api.spreadsheets.values.get(
      _spreadsheetId,
      '$clientsSheet!A2:D',
    );
    final values = response.values ?? [];
    return values.where((row) => row.isNotEmpty).map((row) {
      final cells = List<String>.generate(
        4,
        (index) => index < row.length ? row[index]?.toString() ?? '' : '',
      );
      return {
        'id': cells[0],
        'name': cells[1],
        'pib': cells[2],
        'address': cells[3],
      };
    }).toList();
  }

  Future<Map<String, Map<String, String>>> _fetchRawProfileRows() async {
    final response = await _api.spreadsheets.values.get(
      _spreadsheetId,
      '$profileSheet!A2:C',
    );
    final values = response.values ?? [];
    final Map<String, Map<String, String>> sections = {};

    for (final row in values) {
      if (row.isEmpty) continue;
      final section =
          row.length > 0 ? row[0]?.toString().trim().toLowerCase() : '';
      final field = row.length > 1 ? row[1]?.toString().trim() : '';
      final value = row.length > 2 ? row[2]?.toString() ?? '' : '';
      if (section!.isEmpty || field!.isEmpty) {
        continue;
      }
      final sectionMap = sections.putIfAbsent(section, () => {});
      sectionMap[field] = value;
    }

    return sections;
  }

  Future<Map<String, Map<String, dynamic>>> fetchProfiles() async {
    final sections = await _fetchRawProfileRows();
    final result = <String, Map<String, dynamic>>{};

    final company = sections['company'];
    if (company != null && company.isNotEmpty) {
      result['company'] = {
        'name': company['name'] ?? '',
        'shortName': company['shortName'] ?? '',
        'responsiblePerson': company['responsiblePerson'] ?? '',
        'pib': company['pib'] ?? '',
        'address': company['address'] ?? '',
        'accountNumber': company['accountNumber'] ?? '',
      };
    }

    final tax = sections['tax'];
    if (tax != null && tax.isNotEmpty) {
      double parseDouble(String? value) =>
          double.tryParse(value?.replaceAll(',', '.') ?? '') ?? 0;

      result['tax'] = {
        'city': tax['city'] ?? '',
        'monthlyPension': parseDouble(tax['monthlyPension']),
        'monthlyHealth': parseDouble(tax['monthlyHealth']),
        'monthlyTaxPrepayment': parseDouble(tax['monthlyTaxPrepayment']),
        'annualLimit': parseDouble(tax['annualLimit']),
        'rollingLimit': parseDouble(tax['rollingLimit']),
        'additionalTaxRate': parseDouble(tax['additionalTaxRate']),
      };
    }

    return result;
  }

  Future<void> _ensureSheet(String title, List<String> headers) async {
    final spreadsheet = await _api.spreadsheets.get(_spreadsheetId);
    final sheetExists =
        spreadsheet.sheets?.any((sheet) => sheet.properties?.title == title) ??
        false;

    if (!sheetExists) {
      await _api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: [
            sheets.Request(
              addSheet: sheets.AddSheetRequest(
                properties: sheets.SheetProperties(title: title),
              ),
            ),
          ],
        ),
        _spreadsheetId,
      );
    }

    await _api.spreadsheets.values.update(
      sheets.ValueRange(values: [headers]),
      _spreadsheetId,
      '$title!A1',
      valueInputOption: 'RAW',
    );
  }

  Future<void> _clearSheet(String title) async {
    await _api.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      _spreadsheetId,
      '$title!A2:ZZZ',
    );
  }

  Future<void> _writeRange(
    String sheet,
    List<List<dynamic>> values,
  ) async {
    if (values.isEmpty) {
      return;
    }
    await _api.spreadsheets.values.update(
      sheets.ValueRange(values: values),
      _spreadsheetId,
      '$sheet!A2',
      valueInputOption: 'RAW',
    );
  }

  void close() {
    _client.close();
  }
}
