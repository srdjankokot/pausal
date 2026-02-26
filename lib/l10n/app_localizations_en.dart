// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tax Calculator';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveItem => 'Save Item';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get loading => 'Connecting...';

  @override
  String get landingTitle => 'Tax Calculator';

  @override
  String get landingSubtitle =>
      'Digital assistant for flat-rate taxpayers developed by Finaccons.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get launchApp => 'Launch Application';

  @override
  String get whatAppDoes => 'What the app does';

  @override
  String get featureOverviewTitle => 'Business Overview';

  @override
  String get featureOverviewDesc =>
      'Automatically calculates revenue, expenses, net income and tax obligations under flat-rate taxation.';

  @override
  String get featureClientsTitle => 'Client Management';

  @override
  String get featureClientsDesc =>
      'Track income by client, record contracts and keep track of prescribed limits.';

  @override
  String get featureInvoicingTitle => 'Invoicing';

  @override
  String get featureInvoicingDesc =>
      'Create PDF invoices in accordance with local regulations and share them directly from the app.';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get featureSyncTitle => 'Google Sheets synchronization';

  @override
  String get featureSyncDesc =>
      'Data connects directly to your Google Sheets document – the app reads and updates the same file without a manual export/import process.';

  @override
  String get featureOnboardingTitle => 'Simple onboarding';

  @override
  String get featureOnboardingDesc =>
      'Connect an existing sheet or create a new document with all necessary sheets: expenses, clients and company profile.';

  @override
  String get featureDataControlTitle => 'Complete data control';

  @override
  String get featureDataControlDesc =>
      'Data remains in your Google account. The app only uses permissions you explicitly granted.';

  @override
  String get importantLinks => 'Important links';

  @override
  String get linkPrivacyTitle => 'Privacy Policy';

  @override
  String get linkPrivacyDesc =>
      'Explains in detail which Google accounts and Sheets permissions we use and why.';

  @override
  String get linkSupportTitle => 'Contact Support';

  @override
  String get linkSupportDesc =>
      'Email pausal@finaccons.rs for help with setup or bug reports.';

  @override
  String get linkRoadmapTitle => 'Development Plan';

  @override
  String get linkRoadmapDesc =>
      'Adding client analytics, XML/JPKD format export and much more.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyFullTitle => 'Privacy Policy – Tax Calculator';

  @override
  String get privacyIntro =>
      'This privacy policy explains how Tax Calculator uses and protects data when a user logs in via a Google account and connects their Google Sheets document for calculations and business tracking.';

  @override
  String get privacySectionDataAccess => 'Data we access';

  @override
  String get privacyGoogleAccountTitle => 'Google account (openid)';

  @override
  String get privacyGoogleAccountDesc =>
      'We use the \"openid\" permission to securely log you into the app and connect your account with a unique identifier we receive from Google. We do not use or store your email address for application purposes.';

  @override
  String get privacyGoogleSheetsTitle => 'Google Sheets file you select';

  @override
  String get privacyGoogleSheetsDesc =>
      'The app uses Google Picker and \"drive.file\" permission to allow you to manually select a specific Google Sheets file. After that, Tax Calculator uses the Google Sheets API to read cell values, add new rows, update specific ranges and clear ranges exclusively in that document (e.g. income, expenses, clients). The app has no access to other documents in your Google account.';

  @override
  String get privacySectionScopes => 'Google API permissions (scopes)';

  @override
  String get privacyScopesDetails =>
      'Tax Calculator uses the following Google API permissions that are necessary for the app to work:\n\n• openid – for secure user login.\n• https://www.googleapis.com/auth/spreadsheets – for reading and updating Google Sheets document content (reading ranges, adding rows, updating and deleting cell ranges).\n• https://www.googleapis.com/auth/drive.file – for selecting a specific file on Google Drive via Google Picker.\n\nWe do not use \"email\" permissions or other sensitive or restricted Google API permissions that are not necessary for the application to function. We limit access exclusively to the document that the user manually selects and to the ranges that the app updates for data calculations.';

  @override
  String get privacySectionDataUse => 'How we use data';

  @override
  String get privacyDataUseDetails =>
      'We use access to the Google account and selected Google Sheets document exclusively to:\n\n• enable login to the app,\n• read data from the selected Sheets file for calculations and display in the app,\n• write new entries, add rows, clear specific ranges and update only necessary parts of the document for up-to-date record keeping.\n\nWe do not use your Google data for advertising, marketing or creating user profiles. We do not sell or rent your data to third parties and do not use data from Google Drive/Sheets files to train general AI/ML models.';

  @override
  String get privacySectionDataProtection =>
      'Storage, protection and sharing of data';

  @override
  String get privacyDataProtectionDetails =>
      'The content of your Google Sheets documents remains within your Google account. The app reads this data \"on demand\" and, if necessary, caches it briefly for performance. Such data is stored for the shortest possible time and is protected by appropriate technical measures (HTTPS/TLS, access control, etc.).\n\nWe do not share data with third parties except with trusted technical providers (e.g. hosting), and only to the extent necessary for the app to work, with a contractual obligation to protect data.';

  @override
  String get privacySectionUserRights => 'Your rights and data deletion';

  @override
  String get privacyUserRightsDetails =>
      'You can revoke app access at any time via your Google account page:\nhttps://myaccount.google.com/permissions\n\nYou can also contact us if you want us to delete data stored within the app itself (e.g. local configurations). After identity verification, we will delete or anonymize the data, except for data we are legally required to retain (e.g. accounting records).';

  @override
  String get privacySectionContact => 'Questions and contact';

  @override
  String get privacyContactDetails =>
      'If you have questions about the privacy policy or how the app processes data, you can contact us at:';

  @override
  String get privacyContactEmail => 'pausal@finaccons.rs';

  @override
  String get privacyLastUpdated => 'Last updated: 14.11.2025.';

  @override
  String get navOverview => 'Overview';

  @override
  String get navLedger => 'Ledger';

  @override
  String get navClients => 'Clients';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLogOut => 'Log Out';

  @override
  String get ledgerPageTitle => 'Business Book';

  @override
  String get ledgerPageSubtitle => 'List of all incomes and expenses';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get invoiceNumberShort => 'Invoice number';

  @override
  String get issueDate => 'Issue date';

  @override
  String get invoiceAmount => 'Invoice amount';

  @override
  String get downloadAll => 'Download all';

  @override
  String get googleSheetsSync => 'Google Sheets synchronization';

  @override
  String get connectGoogleSheets => 'Connect Google Sheets';

  @override
  String get connectSheetHeading => 'Connect Google Sheets account';

  @override
  String get connectSheetDescription =>
      'To enter invoices, expenses and clients, you need to connect your Google Sheets document.';

  @override
  String get connectSheetPlaceholder =>
      'Connect to a Google Sheets account to save company and tax data.';

  @override
  String get connectBeforeData => 'Connect Google Sheets before adding data.';

  @override
  String get connectedAs => 'Connected as ';

  @override
  String get googleAccount => 'Google account';

  @override
  String get dataSavedInSheets =>
      'Data is saved directly in the Google Sheet. Connect to create entries.';

  @override
  String get connectDialogTitle => 'Connecting to Google Sheet';

  @override
  String get createNewSheet => 'Create new Google Sheet';

  @override
  String get createNewSheetSubtitle =>
      'The app will automatically create the document and worksheets.';

  @override
  String get documentName => 'Document name';

  @override
  String get documentNameHint => 'Tax Calculator';

  @override
  String get enterDocumentName => 'Enter document name';

  @override
  String get googleSheetDocument => 'Google Sheet document';

  @override
  String get selectGoogleSheetDocument => 'Select Google Sheets document';

  @override
  String get clickToSelectDocument =>
      'Click the icon on the right to select a document.';

  @override
  String get selectFromDrive => 'Select from Google Drive';

  @override
  String get spreadsheetUrlOrId => 'Spreadsheet URL or ID';

  @override
  String get spreadsheetUrlHint => 'https://docs.google.com/... or 1A2B3C...';

  @override
  String get enterFullUrlOrId =>
      'Enter full URL or ID of Google Sheets document';

  @override
  String get sheetForExpenses => 'Sheet for expenses';

  @override
  String get sheetForClients => 'Sheet for clients';

  @override
  String get sheetForProfile => 'Sheet for profile';

  @override
  String get checkingStructure => 'Checking table structure...';

  @override
  String checkingSheetStructure(String sheetName) {
    return 'Checking structure of sheet $sheetName';
  }

  @override
  String get structureConfirmed => 'Structure confirmed';

  @override
  String get loadingInvoices => 'Loading invoices...';

  @override
  String get loadingClients => 'Loading clients...';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get syncCompleted => 'Synchronization completed';

  @override
  String get syncingWithSheets => 'Synchronizing with Google Sheets...';

  @override
  String get checkingSheetsHeaders => 'Checking worksheets and headers...';

  @override
  String get loadingData => 'Data is being loaded.';

  @override
  String get savingToSheets => 'Saving data to Google Sheets…';

  @override
  String get waitForSync => 'Please wait for synchronization to complete.';

  @override
  String get sessionExpired =>
      'Session expired. Please log in again to continue.';

  @override
  String get authError => 'Error authenticating Google account.';

  @override
  String get pickerApiKeyNotConfigured =>
      'Google Picker API key not configured.';

  @override
  String get pickerLoadError =>
      'Unable to load Google Picker. Please try again.';

  @override
  String get syncFailed => 'Google Sheets synchronization failed.';

  @override
  String get autoConnectFailed =>
      'Automatic Google Sheets account connection failed.';

  @override
  String get connectFailed => 'Failed to connect to Google Sheets.';

  @override
  String sheetCreatedSuccess(String spreadsheetId) {
    return 'New Google Sheet created ($spreadsheetId).';
  }

  @override
  String sheetConnectedSuccess(String spreadsheetId) {
    return 'Google Sheets synchronization activated ($spreadsheetId).';
  }

  @override
  String get spreadsheetInfo => 'Spreadsheet ID: ';

  @override
  String selected(String name) {
    return 'Selected: $name';
  }

  @override
  String get overviewGreeting => 'Hello, taxpayer!';

  @override
  String get overviewSubtitle =>
      'Tracking income, expenses and flat-rate tax limits.';

  @override
  String get total => 'Total';

  @override
  String get issuedInvoices => 'Issued invoices';

  @override
  String get expenses => 'Expenses';

  @override
  String get taxObligations => 'Tax obligations';

  @override
  String get estimatedNet => 'Estimated net';

  @override
  String revenueShareByClientYear(String year) {
    return 'Revenue share by client in $year';
  }

  @override
  String get noConnectedClients => 'No connected clients yet.';

  @override
  String get clientLimitWarning =>
      'Make sure no single client exceeds 60% of total revenue.';

  @override
  String get rollingLimit => 'Limit in the last 12 months';

  @override
  String get remainingToLimit => 'Remaining to limit';

  @override
  String get rollingLimitCap => '12-month limit';

  @override
  String periodCovered(String start, String end) {
    return 'Period covered: $start - $end';
  }

  @override
  String get annualLimit => 'Annual limit';

  @override
  String get totalLimit => 'Total limit';

  @override
  String get monthlyObligations => 'Monthly obligations';

  @override
  String get pensionContribution => 'Pension contribution';

  @override
  String get healthInsurance => 'Health insurance';

  @override
  String get taxPrepayment => 'Tax prepayment';

  @override
  String get unemploymentContribution => 'Unemployment contribution';

  @override
  String get totalMonthly => 'Total monthly';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noEntriesYet => 'No entries recorded yet.';

  @override
  String get unknownClient => 'Unknown client';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get allTime => 'All time';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get year => 'Year';

  @override
  String get allYears => 'All years';

  @override
  String get month => 'Month';

  @override
  String get allMonths => 'All months';

  @override
  String get client => 'Client';

  @override
  String get allClients => 'All clients';

  @override
  String get invoices => 'Issued invoices';

  @override
  String get noDataYet => 'No data yet. Add a new entry.';

  @override
  String get clients => 'Clients';

  @override
  String get newClient => 'New Client';

  @override
  String get clientLimitNote =>
      'Make sure no client exceeds 60% of total revenue.';

  @override
  String get noClientsYet => 'No clients yet.';

  @override
  String get addFirstClient => 'Add first client';

  @override
  String get pibLabel => 'Tax ID: ';

  @override
  String get pibNotAvailable => 'N/A';

  @override
  String clientStats(String percent, int invoiceCount, String amount) {
    return 'Share: $percent% · Invoices: $invoiceCount · $amount';
  }

  @override
  String get profileHeading => 'Tax Profile';

  @override
  String get profileHelperText =>
      'Update company and tax data. Company data appears on generated invoices.';

  @override
  String get companyData => 'Company data';

  @override
  String get companyName => 'Company name';

  @override
  String get companyShortName => 'Short name (optional)';

  @override
  String get responsiblePerson => 'Responsible person';

  @override
  String get pib => 'Tax ID';

  @override
  String get address => 'Address';

  @override
  String get accountNumber => 'Account number';

  @override
  String get taxData => 'Tax data';

  @override
  String get city => 'City';

  @override
  String get monthlyPension => 'Pension contribution (monthly)';

  @override
  String get monthlyHealth => 'Health insurance (monthly)';

  @override
  String get monthlyTaxPrepayment => 'Tax prepayment (monthly)';

  @override
  String get annualLimitLabel => 'Annual income limit';

  @override
  String get rollingLimitLabel => 'Limit in the last 12 months';

  @override
  String get additionalTaxRate => 'Additional tax (in %)';

  @override
  String get dataSaved => 'Data saved';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get newEntry => 'New Entry';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get invoiceNumber => 'Invoice number';

  @override
  String get invoiceNumberHint => 'e.g. 10-2025';

  @override
  String get enterInvoiceNumber => 'Enter invoice number';

  @override
  String get invoiceDescription => 'Invoice description';

  @override
  String get expenseName => 'Expense name';

  @override
  String get enterName => 'Enter name';

  @override
  String get invoiceItems => 'Invoice items';

  @override
  String get addItem => 'Add item';

  @override
  String totalFormatted(String amount) {
    return 'Total: $amount';
  }

  @override
  String get selectClientForInvoice => 'Select client for invoice';

  @override
  String get addAtLeastOneItem =>
      'Add at least one item with price and quantity.';

  @override
  String get enterInvoiceNumberError => 'Enter invoice number.';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get autoCalculated => 'Automatically calculated based on items';

  @override
  String get enterAmountGreaterThanZero => 'Enter amount greater than zero';

  @override
  String get date => 'Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get searchClients => 'Search clients';

  @override
  String get noClientsForCriteria => 'No clients matching criteria.';

  @override
  String invoiceItem(int index) {
    return 'Item $index';
  }

  @override
  String get removeItem => 'Remove item';

  @override
  String get itemDescription => 'Item description';

  @override
  String get enterItemDescription => 'Enter item description';

  @override
  String get unitOfMeasure => 'Unit of measure';

  @override
  String get workHour => 'Work hour';

  @override
  String get piece => 'Piece';

  @override
  String get quantity => 'Quantity';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get enterPrice => 'Enter price';

  @override
  String itemAmount(String total) {
    return 'Item amount: $total';
  }

  @override
  String get editClient => 'Edit Client';

  @override
  String get clientName => 'Client name';

  @override
  String get enterClientName => 'Enter client name';

  @override
  String get actions => 'Actions';

  @override
  String get print => 'Print';

  @override
  String get pdfSend => 'PDF / Send';

  @override
  String get addClientBeforePrint => 'Add client before printing invoice.';

  @override
  String get addClientBeforeSend => 'Add client before sending invoice.';

  @override
  String invoiceDetail(String number) {
    return 'Invoice $number';
  }

  @override
  String invoiceShareText(
    String invoiceNumber,
    String clientName,
    String amount,
    String accountNumber,
  ) {
    return 'Invoice $invoiceNumber for $clientName amounts to $amount.\nPayment to account: $accountNumber.';
  }

  @override
  String get fabNewEntry => 'New Entry';

  @override
  String get fabNewClient => 'New Client';

  @override
  String get enterValue => 'Enter name';

  @override
  String get enterNumberGreaterOrEqualZero =>
      'Enter number greater than or equal to zero';

  @override
  String sheetInfo(
    String expensesSheet,
    String clientsSheet,
    String profileSheet,
  ) {
    return 'Sheets: $expensesSheet (expenses), $clientsSheet (clients), $profileSheet (profile)';
  }

  @override
  String connectedAsEmail(String email) {
    return 'Connected as $email';
  }
}
