// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Paušal kalkulator';

  @override
  String get save => 'Sačuvaj';

  @override
  String get saveChanges => 'Sačuvaj promene';

  @override
  String get saveItem => 'Sačuvaj stavku';

  @override
  String get cancel => 'Otkaži';

  @override
  String get delete => 'Obriši';

  @override
  String get edit => 'Uredi';

  @override
  String get connect => 'Poveži';

  @override
  String get disconnect => 'Prekini vezu';

  @override
  String get loading => 'Povezivanje...';

  @override
  String get landingTitle => 'Paušal kalkulator';

  @override
  String get landingSubtitle =>
      'Digitalni asistent za paušalno oporezovane preduzetnike koji razvija Finaccons.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get launchApp => 'Pokreni aplikaciju';

  @override
  String get whatAppDoes => 'Šta aplikacija radi';

  @override
  String get featureOverviewTitle => 'Pregled poslovanja';

  @override
  String get featureOverviewDesc =>
      'Automatski izračunava promet, troškove, neto prihod i poreske obaveze po osnovu paušalnog oporezivanja.';

  @override
  String get featureClientsTitle => 'Upravljanje klijentima';

  @override
  String get featureClientsDesc =>
      'Pratite prihod po klijentu, evidentirajte ugovore i vodite računa o propisanim limitima.';

  @override
  String get featureInvoicingTitle => 'Fakturisanje';

  @override
  String get featureInvoicingDesc =>
      'Kreirajte PDF fakture u skladu sa lokalnim propisima i delite ih direktno iz aplikacije.';

  @override
  String get whatsNew => 'Šta je novo';

  @override
  String get featureSyncTitle => 'Google Sheets sinhronizacija';

  @override
  String get featureSyncDesc =>
      'Podaci se povezuju direktno sa vašim Google Sheets dokumentom – aplikacija čita i ažurira isti fajl bez manualnog export/import procesa.';

  @override
  String get featureOnboardingTitle => 'Jednostavan onboarding';

  @override
  String get featureOnboardingDesc =>
      'Povežite postojeći sheet ili kreirajte novi dokument sa svim potrebnim listovima: troškovi, klijenti i profil firme.';

  @override
  String get featureDataControlTitle => 'Potpuna kontrola podataka';

  @override
  String get featureDataControlDesc =>
      'Podaci ostaju u vašem Google nalogu. Aplikacija koristi samo one dozvole koje ste eksplicitno odobrili.';

  @override
  String get importantLinks => 'Važni linkovi';

  @override
  String get linkPrivacyTitle => 'Politika privatnosti';

  @override
  String get linkPrivacyDesc =>
      'Detaljno objašnjava koje Google naloge i Sheets dozvole koristimo i zašto.';

  @override
  String get linkSupportTitle => 'Kontakt podrška';

  @override
  String get linkSupportDesc =>
      'Pišite na pausal@finaccons.rs za pomoć u podešavanju ili prijavu grešaka.';

  @override
  String get linkRoadmapTitle => 'Plan razvoja';

  @override
  String get linkRoadmapDesc =>
      'Dodavanje analitike po klijentu, eksport u XML/JPKD format i još mnogo toga.';

  @override
  String get privacyPolicyTitle => 'Politika privatnosti';

  @override
  String get privacyPolicyFullTitle =>
      'Politika privatnosti – Paušal kalkulator';

  @override
  String get privacyIntro =>
      'Ova politika privatnosti objašnjava kako Paušal kalkulator koristi i štiti podatke kada se korisnik prijavi putem Google naloga i poveže svoj Google Sheets dokument radi obračuna i praćenja poslovanja.';

  @override
  String get privacySectionDataAccess => 'Podaci kojima pristupamo';

  @override
  String get privacyGoogleAccountTitle => 'Google nalog (openid)';

  @override
  String get privacyGoogleAccountDesc =>
      'Koristimo \"openid\" dozvolu kako bismo vas bezbedno prijavili u aplikaciju i povezali vaš nalog sa jedinstvenim identifikatorom koji dobijamo od Google-a. Ne koristimo i ne čuvamo vašu e-mail adresu za potrebe aplikacije.';

  @override
  String get privacyGoogleSheetsTitle => 'Google Sheets fajl koji izaberete';

  @override
  String get privacyGoogleSheetsDesc =>
      'Aplikacija koristi Google Picker i \"drive.file\" dozvolu kako bi vam omogućila da ručno izaberete konkretan Google Sheets fajl. Nakon toga Paušal kalkulator koristi Google Sheets API kako bi čitao vrednosti ćelija, dodavao nove redove, ažurirao određene opsege i čistio opsege isključivo u tom dokumentu (npr. prihodi, troškovi, klijenti). Aplikacija nema pristup drugim dokumentima na vašem Google nalogu.';

  @override
  String get privacySectionScopes => 'Google API dozvole (scopes)';

  @override
  String get privacyScopesDetails =>
      'Paušal kalkulator koristi sledeće Google API dozvole koje su neophodne za rad aplikacije:\n\n• openid – za bezbednu prijavu korisnika.\n• https://www.googleapis.com/auth/spreadsheets – za čitanje i ažuriranje sadržaja Google Sheets dokumenta (čitanje opsega, dodavanje redova, ažuriranje i brisanje opsega ćelija).\n• https://www.googleapis.com/auth/drive.file – za izbor konkretnog fajla na Google Drive-u putem Google Picker-a.\n\nNe koristimo dozvole \"email\" niti druge osetljive ili ograničene Google API dozvole koje nisu neophodne za funkcionisanje aplikacije. Pristup ograničavamo isključivo na dokument koji korisnik ručno odabere i na opsege koje aplikacija ažurira radi obračuna podataka.';

  @override
  String get privacySectionDataUse => 'Kako koristimo podatke';

  @override
  String get privacyDataUseDetails =>
      'Pristup Google nalogu i odabranom Google Sheets dokumentu koristimo isključivo da bismo:\n\n• omogućili prijavu u aplikaciju,\n• pročitali podatke iz odabranog Sheets fajla radi obračuna i prikaza u aplikaciji,\n• upisali nove unose, dodali redove, očistili određene opsege i ažurirali samo potrebne delove dokumenta radi ažurnog vođenja evidencije.\n\nNe koristimo vaše Google podatke za oglašavanje, marketing ili pravljenje korisničkih profila. Ne prodajemo i ne iznajmljujemo vaše podatke trećim stranama i ne koristimo podatke iz Google Drive/Sheets fajlova za obučavanje opštih AI/ML modela.';

  @override
  String get privacySectionDataProtection =>
      'Čuvanje, zaštita i deljenje podataka';

  @override
  String get privacyDataProtectionDetails =>
      'Sadržaj vaših Google Sheets dokumenata ostaje u okviru vašeg Google naloga. Aplikacija te podatke čita \"na zahtev\" i, po potrebi, kratkotrajno kešira radi performansi. Takvi podaci se čuvaju najkraće moguće vreme i zaštićeni su odgovarajućim tehničkim merama (HTTPS/TLS, kontrola pristupa itd.).\n\nPodatke ne delimo sa trećim stranama osim sa pouzdanim tehničkim provajderima (npr. hosting), i to isključivo u meri u kojoj je neophodno za rad aplikacije, uz ugovornu obavezu zaštite podataka.';

  @override
  String get privacySectionUserRights => 'Vaša prava i brisanje podataka';

  @override
  String get privacyUserRightsDetails =>
      'Pristup aplikaciji možete opozvati u bilo kom trenutku preko stranice vašeg Google naloga:\nhttps://myaccount.google.com/permissions\n\nTakođe, možete nam se obratiti ukoliko želite da obrišemo podatke koji se čuvaju u okviru same aplikacije (npr. lokalne konfiguracije). Nakon potvrde identiteta, obrišaćemo ili anonimizovati podatke, osim onih koje smo zakonski obavezni da zadržimo (npr. knjigovodstvena evidencija).';

  @override
  String get privacySectionContact => 'Pitanja i kontakt';

  @override
  String get privacyContactDetails =>
      'Ako imate pitanja u vezi sa politikom privatnosti ili načinom na koji aplikacija obrađuje podatke, možete nas kontaktirati na:';

  @override
  String get privacyContactEmail => 'pausal@finaccons.rs';

  @override
  String get privacyLastUpdated => 'Poslednje ažuriranje: 14.11.2025.';

  @override
  String get navOverview => 'Pregled';

  @override
  String get navLedger => 'Knjiga';

  @override
  String get navClients => 'Klijenti';

  @override
  String get navProfile => 'Profil';

  @override
  String get navLogOut => 'Odjavi se';

  @override
  String get googleSheetsSync => 'Google Sheets sinhronizacija';

  @override
  String get connectGoogleSheets => 'Poveži Google Sheets';

  @override
  String get connectSheetHeading => 'Povežite Google Sheets nalog';

  @override
  String get connectSheetDescription =>
      'Za unos faktura, troškova i klijenata potrebno je da povežete svoj Google Sheets dokument.';

  @override
  String get connectSheetPlaceholder =>
      'Povežite se sa Google Sheets nalogom da biste čuvali podatke o firmi i porezima.';

  @override
  String get connectBeforeData =>
      'Povežite Google Sheets pre nego što dodate podatke.';

  @override
  String get connectedAs => 'Povezano kao ';

  @override
  String get googleAccount => 'Google nalog';

  @override
  String get dataSavedInSheets =>
      'Podaci se čuvaju direktno u Google Sheet-u. Povežite se kako biste mogli da kreirate stavke.';

  @override
  String get connectDialogTitle => 'Povezivanje sa Google Sheet-om';

  @override
  String get createNewSheet => 'Kreiraj novi Google Sheet';

  @override
  String get createNewSheetSubtitle =>
      'Aplikacija će automatski kreirati dokument i radne listove.';

  @override
  String get documentName => 'Naziv dokumenta';

  @override
  String get documentNameHint => 'Paušal kalkulator';

  @override
  String get enterDocumentName => 'Unesite naziv dokumenta';

  @override
  String get googleSheetDocument => 'Google Sheet dokument';

  @override
  String get selectGoogleSheetDocument => 'Izaberite Google Sheets dokument';

  @override
  String get clickToSelectDocument =>
      'Kliknite na ikonu desno kako biste izabrali dokument.';

  @override
  String get selectFromDrive => 'Izaberi iz Google Drive-a';

  @override
  String get spreadsheetUrlOrId => 'Spreadsheet URL ili ID';

  @override
  String get spreadsheetUrlHint => 'https://docs.google.com/... ili 1A2B3C...';

  @override
  String get enterFullUrlOrId =>
      'Unesite pun URL ili ID Google Sheets dokumenta';

  @override
  String get sheetForExpenses => 'Sheet za troškove';

  @override
  String get sheetForClients => 'Sheet za klijente';

  @override
  String get sheetForProfile => 'Sheet za profil';

  @override
  String get checkingStructure => 'Proveravamo strukturu tabele...';

  @override
  String checkingSheetStructure(String sheetName) {
    return 'Proveravamo strukturu sheet-a $sheetName';
  }

  @override
  String get structureConfirmed => 'Struktura potvrđena';

  @override
  String get loadingInvoices => 'Učitavamo fakture...';

  @override
  String get loadingClients => 'Učitavamo klijente...';

  @override
  String get loadingProfile => 'Učitavamo profil...';

  @override
  String get syncCompleted => 'Sinhronizacija završena';

  @override
  String get syncingWithSheets => 'Sinhronizacija sa Google Sheets...';

  @override
  String get checkingSheetsHeaders =>
      'Proveravamo radne listove i zaglavlja...';

  @override
  String get loadingData => 'U toku je učitavanje podataka.';

  @override
  String get savingToSheets => 'Snimam podatke u Google Sheets…';

  @override
  String get waitForSync => 'Molimo sačekajte dok se sinhronizacija ne završi.';

  @override
  String get sessionExpired =>
      'Sesija je istekla. Prijavite se ponovo da biste nastavili.';

  @override
  String get authError => 'Greška pri autentifikaciji Google naloga.';

  @override
  String get pickerApiKeyNotConfigured =>
      'Google Picker API ključ nije konfigurisan.';

  @override
  String get pickerLoadError =>
      'Nije moguće učitati Google Picker. Pokušajte ponovo.';

  @override
  String get syncFailed => 'Neuspešna sinhronizacija sa Google Sheets.';

  @override
  String get autoConnectFailed =>
      'Automatsko povezivanje Google Sheets naloga nije uspelo.';

  @override
  String get connectFailed => 'Neuspešno povezivanje sa Google Sheets.';

  @override
  String sheetCreatedSuccess(String spreadsheetId) {
    return 'Kreiran je novi Google Sheet ($spreadsheetId).';
  }

  @override
  String sheetConnectedSuccess(String spreadsheetId) {
    return 'Google Sheets sinhronizacija aktivirana ($spreadsheetId).';
  }

  @override
  String get spreadsheetInfo => 'Spreadsheet ID: ';

  @override
  String selected(String name) {
    return 'Odabrano: $name';
  }

  @override
  String get overviewGreeting => 'Dobrodošao, paušalac';

  @override
  String get overviewSubtitle =>
      'Praćenje prihoda, troškova i limita paušalnog oporezivanja.';

  @override
  String get total => 'Ukupno';

  @override
  String get issuedInvoices => 'Izdati računi';

  @override
  String get expenses => 'Troškovi';

  @override
  String get taxObligations => 'Obaveze paušala';

  @override
  String get estimatedNet => 'Procenjeni neto';

  @override
  String revenueShareByClientYear(String year) {
    return 'Udeo prihoda po klijentima u $year. godini';
  }

  @override
  String get noConnectedClients => 'Još uvek nema povezanih klijenata.';

  @override
  String get clientLimitWarning =>
      'Pazite da pojedinačan klijent ne premaši 60% ukupnih prihoda.';

  @override
  String get rollingLimit => 'Limit u poslednjih 12 meseci';

  @override
  String get remainingToLimit => 'Preostalo do limita';

  @override
  String get rollingLimitCap => 'Ograničenje 12m';

  @override
  String periodCovered(String start, String end) {
    return 'Obuhvaćen period: $start - $end';
  }

  @override
  String get annualLimit => 'Godišnji limit';

  @override
  String get totalLimit => 'Ukupan limit';

  @override
  String get monthlyObligations => 'Mesečne obaveze';

  @override
  String get pensionContribution => 'PIO doprinos';

  @override
  String get healthInsurance => 'Zdravstveno osiguranje';

  @override
  String get taxPrepayment => 'Akontacija poreza';

  @override
  String get totalMonthly => 'Ukupno mesečno';

  @override
  String get recentActivity => 'Poslednje aktivnosti';

  @override
  String get noEntriesYet => 'Još uvek nema zabeleženih stavki.';

  @override
  String get unknownClient => 'Nepoznat klijent';

  @override
  String get filters => 'Filteri';

  @override
  String get clearFilters => 'Obriši filtere';

  @override
  String get year => 'Godina';

  @override
  String get allYears => 'Sve godine';

  @override
  String get month => 'Mesec';

  @override
  String get allMonths => 'Svi meseci';

  @override
  String get client => 'Klijent';

  @override
  String get allClients => 'Svi klijenti';

  @override
  String get invoices => 'Izdati računi';

  @override
  String get noDataYet => 'Još uvek nema podataka. Dodajte novu stavku.';

  @override
  String get clients => 'Klijenti';

  @override
  String get newClient => 'Novi klijent';

  @override
  String get clientLimitNote =>
      'Vodite računa da nijedan klijent ne premaši 60% ukupnih prihoda.';

  @override
  String get noClientsYet => 'Još uvek nema klijenata.';

  @override
  String get addFirstClient => 'Dodaj prvog klijenta';

  @override
  String get pibLabel => 'PIB: ';

  @override
  String get pibNotAvailable => 'N/A';

  @override
  String clientStats(String percent, int invoiceCount, String amount) {
    return 'Udeo: $percent% · Računi: $invoiceCount · $amount';
  }

  @override
  String get profileHeading => 'Paušal profil';

  @override
  String get profileHelperText =>
      'Ažurirajte podatke o firmi i paušalu. Podaci o firmi se pojavljuju na generisanim fakturama.';

  @override
  String get companyData => 'Podaci o firmi';

  @override
  String get companyName => 'Naziv firme';

  @override
  String get companyShortName => 'Skraćeni naziv (opciono)';

  @override
  String get responsiblePerson => 'Odgovorno lice';

  @override
  String get pib => 'PIB';

  @override
  String get address => 'Adresa';

  @override
  String get accountNumber => 'Broj računa';

  @override
  String get taxData => 'Poreski podaci paušala';

  @override
  String get city => 'Grad';

  @override
  String get monthlyPension => 'PIO doprinos (mesečno)';

  @override
  String get monthlyHealth => 'Zdravstveno osiguranje (mesečno)';

  @override
  String get monthlyTaxPrepayment => 'Akontacija poreza (mesečno)';

  @override
  String get annualLimitLabel => 'Godišnji limit prihoda';

  @override
  String get rollingLimitLabel => 'Limit u poslednjih 12 meseci';

  @override
  String get additionalTaxRate => 'Dodatni porez (u %)';

  @override
  String get dataSaved => 'Podaci sačuvani';

  @override
  String get editEntry => 'Izmena stavke';

  @override
  String get newEntry => 'Nova stavka';

  @override
  String get income => 'Prihod';

  @override
  String get expense => 'Trošak';

  @override
  String get invoiceNumber => 'Broj fakture';

  @override
  String get invoiceNumberHint => 'npr. 10-2025';

  @override
  String get enterInvoiceNumber => 'Unesite broj fakture';

  @override
  String get invoiceDescription => 'Opis fakture';

  @override
  String get expenseName => 'Naziv troška';

  @override
  String get enterName => 'Unesite naziv';

  @override
  String get invoiceItems => 'Stavke fakture';

  @override
  String get addItem => 'Dodaj stavku';

  @override
  String totalFormatted(String amount) {
    return 'Ukupno: $amount';
  }

  @override
  String get selectClientForInvoice => 'Odaberite klijenta za fakturu';

  @override
  String get addAtLeastOneItem =>
      'Dodajte bar jednu stavku sa cenom i količinom.';

  @override
  String get enterInvoiceNumberError => 'Unesite broj fakture.';

  @override
  String get totalAmount => 'Ukupan iznos';

  @override
  String get autoCalculated => 'Automatski se računa na osnovu stavki';

  @override
  String get enterAmountGreaterThanZero => 'Unesite iznos veći od nule';

  @override
  String get date => 'Datum';

  @override
  String get selectDate => 'Izaberi datum';

  @override
  String get noteOptional => 'Napomena (opciono)';

  @override
  String get searchClients => 'Pretraga klijenata';

  @override
  String get noClientsForCriteria => 'Nema klijenata za zadati kriterijum.';

  @override
  String invoiceItem(int index) {
    return 'Stavka $index';
  }

  @override
  String get removeItem => 'Ukloni stavku';

  @override
  String get itemDescription => 'Opis stavke';

  @override
  String get enterItemDescription => 'Unesite opis stavke';

  @override
  String get unitOfMeasure => 'Jedinica mere';

  @override
  String get workHour => 'Radni sat';

  @override
  String get piece => 'Komad';

  @override
  String get quantity => 'Količina';

  @override
  String get enterQuantity => 'Unesite količinu';

  @override
  String get pricePerUnit => 'Cena po jedinici';

  @override
  String get enterPrice => 'Unesite cenu';

  @override
  String itemAmount(String total) {
    return 'Iznos stavke: $total';
  }

  @override
  String get editClient => 'Izmena klijenta';

  @override
  String get clientName => 'Naziv klijenta';

  @override
  String get enterClientName => 'Unesite naziv klijenta';

  @override
  String get actions => 'Radnje';

  @override
  String get print => 'Štampa';

  @override
  String get pdfSend => 'PDF / Pošalji';

  @override
  String get addClientBeforePrint => 'Dodajte klijenta pre štampe fakture.';

  @override
  String get addClientBeforeSend => 'Dodajte klijenta pre slanja fakture.';

  @override
  String invoiceDetail(String number) {
    return 'Faktura $number';
  }

  @override
  String invoiceShareText(
    String invoiceNumber,
    String clientName,
    String amount,
    String accountNumber,
  ) {
    return 'Faktura $invoiceNumber za $clientName iznosi $amount.\nUplata na račun: $accountNumber.';
  }

  @override
  String get fabNewEntry => 'Nova stavka';

  @override
  String get fabNewClient => 'Novi klijent';

  @override
  String get enterValue => 'Unesite naziv';

  @override
  String get enterNumberGreaterOrEqualZero =>
      'Unesite broj veći ili jednak nuli';

  @override
  String sheetInfo(
    String expensesSheet,
    String clientsSheet,
    String profileSheet,
  ) {
    return 'Sheetovi: $expensesSheet (troškovi), $clientsSheet (klijenti), $profileSheet (profil)';
  }

  @override
  String connectedAsEmail(String email) {
    return 'Povezano kao $email';
  }
}
