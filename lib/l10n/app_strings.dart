/// Centralized application strings for multilanguage support.
/// This file contains all user-facing text strings extracted from the application.
///
/// Usage: Import this file and reference strings via AppStrings.keyName
///
/// TODO: Replace with proper l10n solution (flutter_localizations, intl package, or ARB files)
class AppStrings {
  // ============================================
  // COMMON / GENERAL
  // ============================================
  static const String appTitle = 'Paušal kalkulator';
  static const String save = 'Sačuvaj';
  static const String saveChanges = 'Sačuvaj promene';
  static const String saveItem = 'Sačuvaj stavku';
  static const String cancel = 'Otkaži';
  static const String delete = 'Obriši';
  static const String edit = 'Uredi';
  static const String connect = 'Poveži';
  static const String disconnect = 'Prekini vezu';
  static const String loading = 'Povezivanje...';

  // ============================================
  // LANDING PAGE
  // ============================================
  static const String landingTitle = 'Paušal kalkulator';
  static const String landingSubtitle = 'Digitalni asistent za paušalno oporezovane preduzetnike koji razvija Finaccons.';
  static const String privacyPolicy = 'Privacy Policy';
  static const String launchApp = 'Pokreni aplikaciju';

  // Landing: What the app does
  static const String whatAppDoes = 'Šta aplikacija radi';
  static const String featureOverviewTitle = 'Pregled poslovanja';
  static const String featureOverviewDesc = 'Automatski izračunava promet, troškove, neto prihod i poreske obaveze po osnovu paušalnog oporezivanja.';
  static const String featureClientsTitle = 'Upravljanje klijentima';
  static const String featureClientsDesc = 'Pratite prihod po klijentu, evidentirajte ugovore i vodite računa o propisanim limitima.';
  static const String featureInvoicingTitle = 'Fakturisanje';
  static const String featureInvoicingDesc = 'Kreirajte PDF fakture u skladu sa lokalnim propisima i delite ih direktno iz aplikacije.';

  // Landing: What's new
  static const String whatsNew = 'Šta je novo';
  static const String featureSyncTitle = 'Google Sheets sinhronizacija';
  static const String featureSyncDesc = 'Podaci se povezuju direktno sa vašim Google Sheets dokumentom – aplikacija čita i ažurira isti fajl bez manualnog export/import procesa.';
  static const String featureOnboardingTitle = 'Jednostavan onboarding';
  static const String featureOnboardingDesc = 'Povežite postojeći sheet ili kreirajte novi dokument sa svim potrebnim listovima: troškovi, klijenti i profil firme.';
  static const String featureDataControlTitle = 'Potpuna kontrola podataka';
  static const String featureDataControlDesc = 'Podaci ostaju u vašem Google nalogu. Aplikacija koristi samo one dozvole koje ste eksplicitno odobrili.';

  // Landing: Important links
  static const String importantLinks = 'Važni linkovi';
  static const String linkPrivacyTitle = 'Politika privatnosti';
  static const String linkPrivacyDesc = 'Detaljno objašnjava koje Google naloge i Sheets dozvole koristimo i zašto.';
  static const String linkSupportTitle = 'Kontakt podrška';
  static const String linkSupportDesc = 'Pišite na pausal@finaccons.rs za pomoć u podešavanju ili prijavu grešaka.';
  static const String linkRoadmapTitle = 'Plan razvoja';
  static const String linkRoadmapDesc = 'Dodavanje analitike po klijentu, eksport u XML/JPKD format i još mnogo toga.';

  // ============================================
  // PRIVACY POLICY PAGE
  // ============================================
  static const String privacyPolicyTitle = 'Politika privatnosti';
  static const String privacyPolicyFullTitle = 'Politika privatnosti – Paušal kalkulator';
  static const String privacyIntro = 'Ova politika privatnosti objašnjava kako Paušal kalkulator koristi i štiti podatke kada se korisnik prijavi putem Google naloga i poveže svoj Google Sheets dokument radi obračuna i praćenja poslovanja.';

  static const String privacySectionDataAccess = 'Podaci kojima pristupamo';
  static const String privacyGoogleAccountTitle = 'Google nalog (openid)';
  static const String privacyGoogleAccountDesc = 'Koristimo "openid" dozvolu kako bismo vas bezbedno prijavili u aplikaciju i povezali vaš nalog sa jedinstvenim identifikatorom koji dobijamo od Google-a. Ne koristimo i ne čuvamo vašu e-mail adresu za potrebe aplikacije.';
  static const String privacyGoogleSheetsTitle = 'Google Sheets fajl koji izaberete';
  static const String privacyGoogleSheetsDesc = 'Aplikacija koristi Google Picker i "drive.file" dozvolu kako bi vam omogućila da ručno izaberete konkretan Google Sheets fajl. Nakon toga Paušal kalkulator koristi Google Sheets API kako bi čitao vrednosti ćelija, dodavao nove redove, ažurirao određene opsege i čistio opsege isključivo u tom dokumentu (npr. prihodi, troškovi, klijenti). Aplikacija nema pristup drugim dokumentima na vašem Google nalogu.';

  static const String privacySectionScopes = 'Google API dozvole (scopes)';
  static const String privacyScopesDetails = 'Paušal kalkulator koristi sledeće Google API dozvole koje su neophodne za rad aplikacije:\n\n'
      '• openid – za bezbednu prijavu korisnika.\n'
      '• https://www.googleapis.com/auth/spreadsheets – za čitanje i ažuriranje sadržaja Google Sheets dokumenta (čitanje opsega, dodavanje redova, ažuriranje i brisanje opsega ćelija).\n'
      '• https://www.googleapis.com/auth/drive.file – za izbor konkretnog fajla na Google Drive-u putem Google Picker-a.\n\n'
      'Ne koristimo dozvole "email" niti druge osetljive ili ograničene Google API dozvole koje nisu neophodne za funkcionisanje aplikacije. Pristup ograničavamo isključivo na dokument koji korisnik ručno odabere i na opsege koje aplikacija ažurira radi obračuna podataka.';

  static const String privacySectionDataUse = 'Kako koristimo podatke';
  static const String privacyDataUseDetails = 'Pristup Google nalogu i odabranom Google Sheets dokumentu koristimo isključivo da bismo:\n\n'
      '• omogućili prijavu u aplikaciju,\n'
      '• pročitali podatke iz odabranog Sheets fajla radi obračuna i prikaza u aplikaciji,\n'
      '• upisali nove unose, dodali redove, očistili određene opsege i ažurirali samo potrebne delove dokumenta radi ažurnog vođenja evidencije.\n\n'
      'Ne koristimo vaše Google podatke za oglašavanje, marketing ili pravljenje korisničkih profila. '
      'Ne prodajemo i ne iznajmljujemo vaše podatke trećim stranama i ne koristimo podatke iz Google Drive/Sheets fajlova za obučavanje opštih AI/ML modela.';

  static const String privacySectionDataProtection = 'Čuvanje, zaštita i deljenje podataka';
  static const String privacyDataProtectionDetails = 'Sadržaj vaših Google Sheets dokumenata ostaje u okviru vašeg Google naloga. Aplikacija te podatke čita "na zahtev" i, po potrebi, kratkotrajno kešira radi performansi. '
      'Takvi podaci se čuvaju najkraće moguće vreme i zaštićeni su odgovarajućim tehničkim merama (HTTPS/TLS, kontrola pristupa itd.).\n\n'
      'Podatke ne delimo sa trećim stranama osim sa pouzdanim tehničkim provajderima (npr. hosting), i to isključivo u meri u kojoj je neophodno za rad aplikacije, uz ugovornu obavezu zaštite podataka.';

  static const String privacySectionUserRights = 'Vaša prava i brisanje podataka';
  static const String privacyUserRightsDetails = 'Pristup aplikaciji možete opozvati u bilo kom trenutku preko stranice vašeg Google naloga:\n'
      'https://myaccount.google.com/permissions\n\n'
      'Takođe, možete nam se obratiti ukoliko želite da obrišemo podatke koji se čuvaju u okviru same aplikacije (npr. lokalne konfiguracije). '
      'Nakon potvrde identiteta, obrišaćemo ili anonimizovati podatke, osim onih koje smo zakonski obavezni da zadržimo (npr. knjigovodstvena evidencija).';

  static const String privacySectionContact = 'Pitanja i kontakt';
  static const String privacyContactDetails = 'Ako imate pitanja u vezi sa politikom privatnosti ili načinom na koji aplikacija obrađuje podatke, možete nas kontaktirati na:';
  static const String privacyContactEmail = 'pausal@finaccons.rs';
  static const String privacyLastUpdated = 'Poslednje ažuriranje: 14.11.2025.';

  // ============================================
  // NAVIGATION
  // ============================================
  static const String navOverview = 'Pregled';
  static const String navLedger = 'Knjiga';
  static const String navClients = 'Klijenti';
  static const String navProfile = 'Profil';

  // ============================================
  // GOOGLE SHEETS CONNECTION
  // ============================================
  static const String googleSheetsSync = 'Google Sheets sinhronizacija';
  static const String connectGoogleSheets = 'Poveži Google Sheets';
  static const String connectSheetHeading = 'Povežite Google Sheets nalog';
  static const String connectSheetDescription = 'Za unos faktura, troškova i klijenata potrebno je da povežete svoj Google Sheets dokument.';
  static const String connectSheetPlaceholder = 'Povežite se sa Google Sheets nalogom da biste čuvali podatke o firmi i porezima.';
  static const String connectBeforeData = 'Povežite Google Sheets pre nego što dodate podatke.';
  static const String connectedAs = 'Povezano kao ';
  static const String googleAccount = 'Google nalog';
  static const String dataSavedInSheets = 'Podaci se čuvaju direktno u Google Sheet-u. Povežite se kako biste mogli da kreirate stavke.';

  // Connection Dialog
  static const String connectDialogTitle = 'Povezivanje sa Google Sheet-om';
  static const String createNewSheet = 'Kreiraj novi Google Sheet';
  static const String createNewSheetSubtitle = 'Aplikacija će automatski kreirati dokument i radne listove.';
  static const String documentName = 'Naziv dokumenta';
  static const String documentNameHint = 'Paušal kalkulator';
  static const String enterDocumentName = 'Unesite naziv dokumenta';
  static const String googleSheetDocument = 'Google Sheet dokument';
  static const String selectGoogleSheetDocument = 'Izaberite Google Sheets dokument';
  static const String clickToSelectDocument = 'Kliknite na ikonu desno kako biste izabrali dokument.';
  static const String selectFromDrive = 'Izaberi iz Google Drive-a';
  static const String spreadsheetUrlOrId = 'Spreadsheet URL ili ID';
  static const String spreadsheetUrlHint = 'https://docs.google.com/... ili 1A2B3C...';
  static const String enterFullUrlOrId = 'Unesite pun URL ili ID Google Sheets dokumenta';
  static const String sheetForExpenses = 'Sheet za troškove';
  static const String sheetForClients = 'Sheet za klijente';
  static const String sheetForProfile = 'Sheet za profil';

  // Connection Status Messages
  static const String checkingStructure = 'Proveravamo strukturu tabele...';
  static const String structureConfirmed = 'Struktura potvrđena';
  static const String loadingInvoices = 'Učitavamo fakture...';
  static const String loadingClients = 'Učitavamo klijente...';
  static const String loadingProfile = 'Učitavamo profil...';
  static const String syncCompleted = 'Sinhronizacija završena';
  static const String syncingWithSheets = 'Sinhronizacija sa Google Sheets...';
  static const String checkingSheetsHeaders = 'Proveravamo radne listove i zaglavlja...';
  static const String loadingData = 'U toku je učitavanje podataka.';
  static const String savingToSheets = 'Snimam podatke u Google Sheets…';
  static const String waitForSync = 'Molimo sačekajte dok se sinhronizacija ne završi.';

  // Error Messages
  static const String sessionExpired = 'Sesija je istekla. Prijavite se ponovo da biste nastavili.';
  static const String authError = 'Greška pri autentifikaciji Google naloga.';
  static const String pickerApiKeyNotConfigured = 'Google Picker API ključ nije konfigurisan.';
  static const String pickerLoadError = 'Nije moguće učitati Google Picker. Pokušajte ponovo.';
  static const String syncFailed = 'Neuspešna sinhronizacija sa Google Sheets.';
  static const String autoConnectFailed = 'Automatsko povezivanje Google Sheets naloga nije uspelo.';
  static const String connectFailed = 'Neuspešno povezivanje sa Google Sheets.';

  // Success Messages
  static const String sheetCreatedSuccess = 'Kreiran je novi Google Sheet';
  static const String sheetConnectedSuccess = 'Google Sheets sinhronizacija aktivirana';
  static const String spreadsheetInfo = 'Spreadsheet ID: ';

  // ============================================
  // OVERVIEW TAB
  // ============================================
  static const String overviewGreeting = 'Dobrodošao, paušalac';
  static const String overviewSubtitle = 'Praćenje prihoda, troškova i limita paušalnog oporezivanja.';
  static const String total = 'Ukupno';
  static const String issuedInvoices = 'Izdati računi';
  static const String expenses = 'Troškovi';
  static const String taxObligations = 'Obaveze paušala';
  static const String estimatedNet = 'Procenjeni neto';
  static const String revenueShareByClient = 'Udeo prihoda po klijentima u ';
  static const String yearSuffix = '. godini';
  static const String noConnectedClients = 'Još uvek nema povezanih klijenata.';
  static const String clientLimitWarning = 'Pazite da pojedinačan klijent ne premaši 60% ukupnih prihoda.';
  static const String rollingLimit = 'Limit u poslednjih 12 meseci';
  static const String remainingToLimit = 'Preostalo do limita';
  static const String rollingLimitCap = 'Ograničenje 12m';
  static const String annualLimit = 'Godišnji limit';
  static const String totalLimit = 'Ukupan limit';
  static const String monthlyObligations = 'Mesečne obaveze';
  static const String pensionContribution = 'PIO doprinos';
  static const String healthInsurance = 'Zdravstveno osiguranje';
  static const String taxPrepayment = 'Akontacija poreza';
  static const String totalMonthly = 'Ukupno mesečno';
  static const String recentActivity = 'Poslednje aktivnosti';
  static const String noEntriesYet = 'Još uvek nema zabeleženih stavki.';
  static const String unknownClient = 'Nepoznat klijent';

  // ============================================
  // LEDGER TAB
  // ============================================
  static const String filters = 'Filteri';
  static const String clearFilters = 'Obriši filtere';
  static const String year = 'Godina';
  static const String allYears = 'Sve godine';
  static const String month = 'Mesec';
  static const String allMonths = 'Svi meseci';
  static const String client = 'Klijent';
  static const String allClients = 'Svi klijenti';
  static const String invoices = 'Izdati računi';
  static const String noDataYet = 'Još uvek nema podataka. Dodajte novu stavku.';

  // ============================================
  // CLIENTS TAB
  // ============================================
  static const String clients = 'Klijenti';
  static const String newClient = 'Novi klijent';
  static const String clientLimitNote = 'Vodite računa da nijedan klijent ne premaši 60% ukupnih prihoda.';
  static const String noClientsYet = 'Još uvek nema klijenata.';
  static const String addFirstClient = 'Dodaj prvog klijenta';
  static const String pibLabel = 'PIB: ';
  static const String pibNotAvailable = 'N/A';

  // ============================================
  // SETTINGS / PROFILE TAB
  // ============================================
  static const String profileHeading = 'Paušal profil';
  static const String profileHelperText = 'Ažurirajte podatke o firmi i paušalu. Podaci o firmi se pojavljuju na generisanim fakturama.';
  static const String companyData = 'Podaci o firmi';
  static const String companyName = 'Naziv firme';
  static const String companyShortName = 'Skraćeni naziv (opciono)';
  static const String responsiblePerson = 'Odgovorno lice';
  static const String pib = 'PIB';
  static const String address = 'Adresa';
  static const String accountNumber = 'Broj računa';
  static const String taxData = 'Poreski podaci paušala';
  static const String city = 'Grad';
  static const String monthlyPension = 'PIO doprinos (mesečno)';
  static const String monthlyHealth = 'Zdravstveno osiguranje (mesečno)';
  static const String monthlyTaxPrepayment = 'Akontacija poreza (mesečno)';
  static const String annualLimitLabel = 'Godišnji limit prihoda';
  static const String rollingLimitLabel = 'Limit u poslednjih 12 meseci';
  static const String additionalTaxRate = 'Dodatni porez (u %)';
  static const String dataSaved = 'Podaci sačuvani';

  // ============================================
  // ADD ENTRY / INVOICE
  // ============================================
  static const String editEntry = 'Izmena stavke';
  static const String newEntry = 'Nova stavka';
  static const String income = 'Prihod';
  static const String expense = 'Trošak';
  static const String invoiceNumber = 'Broj fakture';
  static const String invoiceNumberHint = 'npr. 10-2025';
  static const String enterInvoiceNumber = 'Unesite broj fakture';
  static const String invoiceDescription = 'Opis fakture';
  static const String expenseName = 'Naziv troška';
  static const String enterName = 'Unesite naziv';
  static const String invoiceItems = 'Stavke fakture';
  static const String addItem = 'Dodaj stavku';
  static const String selectClientForInvoice = 'Odaberite klijenta za fakturu';
  static const String addAtLeastOneItem = 'Dodajte bar jednu stavku sa cenom i količinom.';
  static const String enterInvoiceNumberError = 'Unesite broj fakture.';
  static const String totalAmount = 'Ukupan iznos';
  static const String autoCalculated = 'Automatski se računa na osnovu stavki';
  static const String enterAmountGreaterThanZero = 'Unesite iznos veći od nule';
  static const String date = 'Datum';
  static const String selectDate = 'Izaberi datum';
  static const String noteOptional = 'Napomena (opciono)';
  static const String searchClients = 'Pretraga klijenata';
  static const String noClientsForCriteria = 'Nema klijenata za zadati kriterijum.';

  // Invoice Items
  static const String invoiceItem = 'Stavka ';
  static const String removeItem = 'Ukloni stavku';
  static const String itemDescription = 'Opis stavke';
  static const String enterItemDescription = 'Unesite opis stavke';
  static const String unitOfMeasure = 'Jedinica mere';
  static const String workHour = 'Radni sat';
  static const String piece = 'Komad';
  static const String quantity = 'Količina';
  static const String enterQuantity = 'Unesite količinu';
  static const String pricePerUnit = 'Cena po jedinici';
  static const String enterPrice = 'Unesite cenu';
  static const String itemAmount = 'Iznos stavke: ';

  // ============================================
  // ADD CLIENT
  // ============================================
  static const String editClient = 'Izmena klijenta';
  static const String clientName = 'Naziv klijenta';
  static const String enterClientName = 'Unesite naziv klijenta';

  // ============================================
  // INVOICE ACTIONS
  // ============================================
  static const String actions = 'Radnje';
  static const String print = 'Štampa';
  static const String pdfSend = 'PDF / Pošalji';
  static const String addClientBeforePrint = 'Dodajte klijenta pre štampe fakture.';
  static const String addClientBeforeSend = 'Dodajte klijenta pre slanja fakture.';
  static const String invoice = 'Faktura ';
  static const String forClient = ' za ';
  static const String amounts = ' iznosi ';
  static const String paymentToAccount = '\nUplata na račun: ';

  // ============================================
  // FLOATING ACTION BUTTONS
  // ============================================
  static const String fabNewEntry = 'Nova stavka';
  static const String fabNewClient = 'Novi klijent';

  // ============================================
  // VALIDATION MESSAGES
  // ============================================
  static const String enterValue = 'Unesite naziv';
  static const String enterNumberGreaterOrEqualZero = 'Unesite broj veći ili jednak nuli';

  // ============================================
  // FORMATTED STRINGS (WITH PARAMETERS)
  // ============================================
  static String checkingSheetStructure(String sheetName) => 'Proveravamo strukturu sheet-a $sheetName';
  static String selected(String name) => 'Odabrano: $name';
  static String totalFormatted(String amount) => 'Ukupno: $amount';
  static String sheetInfo(String expensesSheet, String clientsSheet, String profileSheet) =>
      'Sheetovi: $expensesSheet (troškovi), $clientsSheet (klijenti), $profileSheet (profil)';
  static String periodCovered(String start, String end) => 'Obuhvaćen period: $start - $end';
  static String clientStats(String percent, int invoiceCount, String amount) =>
      'Udeo: ${percent}% · Računi: $invoiceCount · $amount';
  static String invoiceDetail(String number) => 'Faktura $number';
  static String connectedAsEmail(String? email) => 'Povezano kao ${email ?? 'Google nalog'}';
  static String invoiceForClient(String invoiceNumber, String title, String clientName, String amount, String accountNumber) =>
      'Faktura ${invoiceNumber.isNotEmpty ? invoiceNumber : title} za $clientName iznosi $amount.\nUplata na račun: $accountNumber.';
}
