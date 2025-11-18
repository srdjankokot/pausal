class SpreadsheetConfig {
  const SpreadsheetConfig({
    required this.createNew,
    this.spreadsheetId,
    this.spreadsheetTitle,
    required this.expensesSheet,
    required this.clientsSheet,
    required this.profileSheet,
  }) : assert(
         createNew ? spreadsheetTitle != null : spreadsheetId != null,
         'Spreadsheet configuration is invalid.',
       );

  final bool createNew;
  final String? spreadsheetId;
  final String? spreadsheetTitle;
  final String expensesSheet;
  final String clientsSheet;
  final String profileSheet;
}

