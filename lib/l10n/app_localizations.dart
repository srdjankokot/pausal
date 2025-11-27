import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
  ];

  /// Application title
  ///
  /// In sr, this message translates to:
  /// **'Paušal kalkulator'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvaj'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvaj promene'**
  String get saveChanges;

  /// No description provided for @saveItem.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvaj stavku'**
  String get saveItem;

  /// No description provided for @cancel.
  ///
  /// In sr, this message translates to:
  /// **'Otkaži'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In sr, this message translates to:
  /// **'Obriši'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In sr, this message translates to:
  /// **'Uredi'**
  String get edit;

  /// No description provided for @connect.
  ///
  /// In sr, this message translates to:
  /// **'Poveži'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In sr, this message translates to:
  /// **'Prekini vezu'**
  String get disconnect;

  /// No description provided for @loading.
  ///
  /// In sr, this message translates to:
  /// **'Povezivanje...'**
  String get loading;

  /// No description provided for @landingTitle.
  ///
  /// In sr, this message translates to:
  /// **'Paušal kalkulator'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In sr, this message translates to:
  /// **'Digitalni asistent za paušalno oporezovane preduzetnike koji razvija Finaccons.'**
  String get landingSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In sr, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @launchApp.
  ///
  /// In sr, this message translates to:
  /// **'Pokreni aplikaciju'**
  String get launchApp;

  /// No description provided for @whatAppDoes.
  ///
  /// In sr, this message translates to:
  /// **'Šta aplikacija radi'**
  String get whatAppDoes;

  /// No description provided for @featureOverviewTitle.
  ///
  /// In sr, this message translates to:
  /// **'Pregled poslovanja'**
  String get featureOverviewTitle;

  /// No description provided for @featureOverviewDesc.
  ///
  /// In sr, this message translates to:
  /// **'Automatski izračunava promet, troškove, neto prihod i poreske obaveze po osnovu paušalnog oporezivanja.'**
  String get featureOverviewDesc;

  /// No description provided for @featureClientsTitle.
  ///
  /// In sr, this message translates to:
  /// **'Upravljanje klijentima'**
  String get featureClientsTitle;

  /// No description provided for @featureClientsDesc.
  ///
  /// In sr, this message translates to:
  /// **'Pratite prihod po klijentu, evidentirajte ugovore i vodite računa o propisanim limitima.'**
  String get featureClientsDesc;

  /// No description provided for @featureInvoicingTitle.
  ///
  /// In sr, this message translates to:
  /// **'Fakturisanje'**
  String get featureInvoicingTitle;

  /// No description provided for @featureInvoicingDesc.
  ///
  /// In sr, this message translates to:
  /// **'Kreirajte PDF fakture u skladu sa lokalnim propisima i delite ih direktno iz aplikacije.'**
  String get featureInvoicingDesc;

  /// No description provided for @whatsNew.
  ///
  /// In sr, this message translates to:
  /// **'Šta je novo'**
  String get whatsNew;

  /// No description provided for @featureSyncTitle.
  ///
  /// In sr, this message translates to:
  /// **'Google Sheets sinhronizacija'**
  String get featureSyncTitle;

  /// No description provided for @featureSyncDesc.
  ///
  /// In sr, this message translates to:
  /// **'Podaci se povezuju direktno sa vašim Google Sheets dokumentom – aplikacija čita i ažurira isti fajl bez manualnog export/import procesa.'**
  String get featureSyncDesc;

  /// No description provided for @featureOnboardingTitle.
  ///
  /// In sr, this message translates to:
  /// **'Jednostavan onboarding'**
  String get featureOnboardingTitle;

  /// No description provided for @featureOnboardingDesc.
  ///
  /// In sr, this message translates to:
  /// **'Povežite postojeći sheet ili kreirajte novi dokument sa svim potrebnim listovima: troškovi, klijenti i profil firme.'**
  String get featureOnboardingDesc;

  /// No description provided for @featureDataControlTitle.
  ///
  /// In sr, this message translates to:
  /// **'Potpuna kontrola podataka'**
  String get featureDataControlTitle;

  /// No description provided for @featureDataControlDesc.
  ///
  /// In sr, this message translates to:
  /// **'Podaci ostaju u vašem Google nalogu. Aplikacija koristi samo one dozvole koje ste eksplicitno odobrili.'**
  String get featureDataControlDesc;

  /// No description provided for @importantLinks.
  ///
  /// In sr, this message translates to:
  /// **'Važni linkovi'**
  String get importantLinks;

  /// No description provided for @linkPrivacyTitle.
  ///
  /// In sr, this message translates to:
  /// **'Politika privatnosti'**
  String get linkPrivacyTitle;

  /// No description provided for @linkPrivacyDesc.
  ///
  /// In sr, this message translates to:
  /// **'Detaljno objašnjava koje Google naloge i Sheets dozvole koristimo i zašto.'**
  String get linkPrivacyDesc;

  /// No description provided for @linkSupportTitle.
  ///
  /// In sr, this message translates to:
  /// **'Kontakt podrška'**
  String get linkSupportTitle;

  /// No description provided for @linkSupportDesc.
  ///
  /// In sr, this message translates to:
  /// **'Pišite na pausal@finaccons.rs za pomoć u podešavanju ili prijavu grešaka.'**
  String get linkSupportDesc;

  /// No description provided for @linkRoadmapTitle.
  ///
  /// In sr, this message translates to:
  /// **'Plan razvoja'**
  String get linkRoadmapTitle;

  /// No description provided for @linkRoadmapDesc.
  ///
  /// In sr, this message translates to:
  /// **'Dodavanje analitike po klijentu, eksport u XML/JPKD format i još mnogo toga.'**
  String get linkRoadmapDesc;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In sr, this message translates to:
  /// **'Politika privatnosti'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyFullTitle.
  ///
  /// In sr, this message translates to:
  /// **'Politika privatnosti – Paušal kalkulator'**
  String get privacyPolicyFullTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In sr, this message translates to:
  /// **'Ova politika privatnosti objašnjava kako Paušal kalkulator koristi i štiti podatke kada se korisnik prijavi putem Google naloga i poveže svoj Google Sheets dokument radi obračuna i praćenja poslovanja.'**
  String get privacyIntro;

  /// No description provided for @privacySectionDataAccess.
  ///
  /// In sr, this message translates to:
  /// **'Podaci kojima pristupamo'**
  String get privacySectionDataAccess;

  /// No description provided for @privacyGoogleAccountTitle.
  ///
  /// In sr, this message translates to:
  /// **'Google nalog (openid)'**
  String get privacyGoogleAccountTitle;

  /// No description provided for @privacyGoogleAccountDesc.
  ///
  /// In sr, this message translates to:
  /// **'Koristimo \"openid\" dozvolu kako bismo vas bezbedno prijavili u aplikaciju i povezali vaš nalog sa jedinstvenim identifikatorom koji dobijamo od Google-a. Ne koristimo i ne čuvamo vašu e-mail adresu za potrebe aplikacije.'**
  String get privacyGoogleAccountDesc;

  /// No description provided for @privacyGoogleSheetsTitle.
  ///
  /// In sr, this message translates to:
  /// **'Google Sheets fajl koji izaberete'**
  String get privacyGoogleSheetsTitle;

  /// No description provided for @privacyGoogleSheetsDesc.
  ///
  /// In sr, this message translates to:
  /// **'Aplikacija koristi Google Picker i \"drive.file\" dozvolu kako bi vam omogućila da ručno izaberete konkretan Google Sheets fajl. Nakon toga Paušal kalkulator koristi Google Sheets API kako bi čitao vrednosti ćelija, dodavao nove redove, ažurirao određene opsege i čistio opsege isključivo u tom dokumentu (npr. prihodi, troškovi, klijenti). Aplikacija nema pristup drugim dokumentima na vašem Google nalogu.'**
  String get privacyGoogleSheetsDesc;

  /// No description provided for @privacySectionScopes.
  ///
  /// In sr, this message translates to:
  /// **'Google API dozvole (scopes)'**
  String get privacySectionScopes;

  /// No description provided for @privacyScopesDetails.
  ///
  /// In sr, this message translates to:
  /// **'Paušal kalkulator koristi sledeće Google API dozvole koje su neophodne za rad aplikacije:\n\n• openid – za bezbednu prijavu korisnika.\n• https://www.googleapis.com/auth/spreadsheets – za čitanje i ažuriranje sadržaja Google Sheets dokumenta (čitanje opsega, dodavanje redova, ažuriranje i brisanje opsega ćelija).\n• https://www.googleapis.com/auth/drive.file – za izbor konkretnog fajla na Google Drive-u putem Google Picker-a.\n\nNe koristimo dozvole \"email\" niti druge osetljive ili ograničene Google API dozvole koje nisu neophodne za funkcionisanje aplikacije. Pristup ograničavamo isključivo na dokument koji korisnik ručno odabere i na opsege koje aplikacija ažurira radi obračuna podataka.'**
  String get privacyScopesDetails;

  /// No description provided for @privacySectionDataUse.
  ///
  /// In sr, this message translates to:
  /// **'Kako koristimo podatke'**
  String get privacySectionDataUse;

  /// No description provided for @privacyDataUseDetails.
  ///
  /// In sr, this message translates to:
  /// **'Pristup Google nalogu i odabranom Google Sheets dokumentu koristimo isključivo da bismo:\n\n• omogućili prijavu u aplikaciju,\n• pročitali podatke iz odabranog Sheets fajla radi obračuna i prikaza u aplikaciji,\n• upisali nove unose, dodali redove, očistili određene opsege i ažurirali samo potrebne delove dokumenta radi ažurnog vođenja evidencije.\n\nNe koristimo vaše Google podatke za oglašavanje, marketing ili pravljenje korisničkih profila. Ne prodajemo i ne iznajmljujemo vaše podatke trećim stranama i ne koristimo podatke iz Google Drive/Sheets fajlova za obučavanje opštih AI/ML modela.'**
  String get privacyDataUseDetails;

  /// No description provided for @privacySectionDataProtection.
  ///
  /// In sr, this message translates to:
  /// **'Čuvanje, zaštita i deljenje podataka'**
  String get privacySectionDataProtection;

  /// No description provided for @privacyDataProtectionDetails.
  ///
  /// In sr, this message translates to:
  /// **'Sadržaj vaših Google Sheets dokumenata ostaje u okviru vašeg Google naloga. Aplikacija te podatke čita \"na zahtev\" i, po potrebi, kratkotrajno kešira radi performansi. Takvi podaci se čuvaju najkraće moguće vreme i zaštićeni su odgovarajućim tehničkim merama (HTTPS/TLS, kontrola pristupa itd.).\n\nPodatke ne delimo sa trećim stranama osim sa pouzdanim tehničkim provajderima (npr. hosting), i to isključivo u meri u kojoj je neophodno za rad aplikacije, uz ugovornu obavezu zaštite podataka.'**
  String get privacyDataProtectionDetails;

  /// No description provided for @privacySectionUserRights.
  ///
  /// In sr, this message translates to:
  /// **'Vaša prava i brisanje podataka'**
  String get privacySectionUserRights;

  /// No description provided for @privacyUserRightsDetails.
  ///
  /// In sr, this message translates to:
  /// **'Pristup aplikaciji možete opozvati u bilo kom trenutku preko stranice vašeg Google naloga:\nhttps://myaccount.google.com/permissions\n\nTakođe, možete nam se obratiti ukoliko želite da obrišemo podatke koji se čuvaju u okviru same aplikacije (npr. lokalne konfiguracije). Nakon potvrde identiteta, obrišaćemo ili anonimizovati podatke, osim onih koje smo zakonski obavezni da zadržimo (npr. knjigovodstvena evidencija).'**
  String get privacyUserRightsDetails;

  /// No description provided for @privacySectionContact.
  ///
  /// In sr, this message translates to:
  /// **'Pitanja i kontakt'**
  String get privacySectionContact;

  /// No description provided for @privacyContactDetails.
  ///
  /// In sr, this message translates to:
  /// **'Ako imate pitanja u vezi sa politikom privatnosti ili načinom na koji aplikacija obrađuje podatke, možete nas kontaktirati na:'**
  String get privacyContactDetails;

  /// No description provided for @privacyContactEmail.
  ///
  /// In sr, this message translates to:
  /// **'pausal@finaccons.rs'**
  String get privacyContactEmail;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In sr, this message translates to:
  /// **'Poslednje ažuriranje: 14.11.2025.'**
  String get privacyLastUpdated;

  /// No description provided for @navOverview.
  ///
  /// In sr, this message translates to:
  /// **'Pregled'**
  String get navOverview;

  /// No description provided for @navLedger.
  ///
  /// In sr, this message translates to:
  /// **'Knjiga'**
  String get navLedger;

  /// No description provided for @navClients.
  ///
  /// In sr, this message translates to:
  /// **'Klijenti'**
  String get navClients;

  /// No description provided for @navProfile.
  ///
  /// In sr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @googleSheetsSync.
  ///
  /// In sr, this message translates to:
  /// **'Google Sheets sinhronizacija'**
  String get googleSheetsSync;

  /// No description provided for @connectGoogleSheets.
  ///
  /// In sr, this message translates to:
  /// **'Poveži Google Sheets'**
  String get connectGoogleSheets;

  /// No description provided for @connectSheetHeading.
  ///
  /// In sr, this message translates to:
  /// **'Povežite Google Sheets nalog'**
  String get connectSheetHeading;

  /// No description provided for @connectSheetDescription.
  ///
  /// In sr, this message translates to:
  /// **'Za unos faktura, troškova i klijenata potrebno je da povežete svoj Google Sheets dokument.'**
  String get connectSheetDescription;

  /// No description provided for @connectSheetPlaceholder.
  ///
  /// In sr, this message translates to:
  /// **'Povežite se sa Google Sheets nalogom da biste čuvali podatke o firmi i porezima.'**
  String get connectSheetPlaceholder;

  /// No description provided for @connectBeforeData.
  ///
  /// In sr, this message translates to:
  /// **'Povežite Google Sheets pre nego što dodate podatke.'**
  String get connectBeforeData;

  /// No description provided for @connectedAs.
  ///
  /// In sr, this message translates to:
  /// **'Povezano kao '**
  String get connectedAs;

  /// No description provided for @googleAccount.
  ///
  /// In sr, this message translates to:
  /// **'Google nalog'**
  String get googleAccount;

  /// No description provided for @dataSavedInSheets.
  ///
  /// In sr, this message translates to:
  /// **'Podaci se čuvaju direktno u Google Sheet-u. Povežite se kako biste mogli da kreirate stavke.'**
  String get dataSavedInSheets;

  /// No description provided for @connectDialogTitle.
  ///
  /// In sr, this message translates to:
  /// **'Povezivanje sa Google Sheet-om'**
  String get connectDialogTitle;

  /// No description provided for @createNewSheet.
  ///
  /// In sr, this message translates to:
  /// **'Kreiraj novi Google Sheet'**
  String get createNewSheet;

  /// No description provided for @createNewSheetSubtitle.
  ///
  /// In sr, this message translates to:
  /// **'Aplikacija će automatski kreirati dokument i radne listove.'**
  String get createNewSheetSubtitle;

  /// No description provided for @documentName.
  ///
  /// In sr, this message translates to:
  /// **'Naziv dokumenta'**
  String get documentName;

  /// No description provided for @documentNameHint.
  ///
  /// In sr, this message translates to:
  /// **'Paušal kalkulator'**
  String get documentNameHint;

  /// No description provided for @enterDocumentName.
  ///
  /// In sr, this message translates to:
  /// **'Unesite naziv dokumenta'**
  String get enterDocumentName;

  /// No description provided for @googleSheetDocument.
  ///
  /// In sr, this message translates to:
  /// **'Google Sheet dokument'**
  String get googleSheetDocument;

  /// No description provided for @selectGoogleSheetDocument.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite Google Sheets dokument'**
  String get selectGoogleSheetDocument;

  /// No description provided for @clickToSelectDocument.
  ///
  /// In sr, this message translates to:
  /// **'Kliknite na ikonu desno kako biste izabrali dokument.'**
  String get clickToSelectDocument;

  /// No description provided for @selectFromDrive.
  ///
  /// In sr, this message translates to:
  /// **'Izaberi iz Google Drive-a'**
  String get selectFromDrive;

  /// No description provided for @spreadsheetUrlOrId.
  ///
  /// In sr, this message translates to:
  /// **'Spreadsheet URL ili ID'**
  String get spreadsheetUrlOrId;

  /// No description provided for @spreadsheetUrlHint.
  ///
  /// In sr, this message translates to:
  /// **'https://docs.google.com/... ili 1A2B3C...'**
  String get spreadsheetUrlHint;

  /// No description provided for @enterFullUrlOrId.
  ///
  /// In sr, this message translates to:
  /// **'Unesite pun URL ili ID Google Sheets dokumenta'**
  String get enterFullUrlOrId;

  /// No description provided for @sheetForExpenses.
  ///
  /// In sr, this message translates to:
  /// **'Sheet za troškove'**
  String get sheetForExpenses;

  /// No description provided for @sheetForClients.
  ///
  /// In sr, this message translates to:
  /// **'Sheet za klijente'**
  String get sheetForClients;

  /// No description provided for @sheetForProfile.
  ///
  /// In sr, this message translates to:
  /// **'Sheet za profil'**
  String get sheetForProfile;

  /// No description provided for @checkingStructure.
  ///
  /// In sr, this message translates to:
  /// **'Proveravamo strukturu tabele...'**
  String get checkingStructure;

  /// No description provided for @checkingSheetStructure.
  ///
  /// In sr, this message translates to:
  /// **'Proveravamo strukturu sheet-a {sheetName}'**
  String checkingSheetStructure(String sheetName);

  /// No description provided for @structureConfirmed.
  ///
  /// In sr, this message translates to:
  /// **'Struktura potvrđena'**
  String get structureConfirmed;

  /// No description provided for @loadingInvoices.
  ///
  /// In sr, this message translates to:
  /// **'Učitavamo fakture...'**
  String get loadingInvoices;

  /// No description provided for @loadingClients.
  ///
  /// In sr, this message translates to:
  /// **'Učitavamo klijente...'**
  String get loadingClients;

  /// No description provided for @loadingProfile.
  ///
  /// In sr, this message translates to:
  /// **'Učitavamo profil...'**
  String get loadingProfile;

  /// No description provided for @syncCompleted.
  ///
  /// In sr, this message translates to:
  /// **'Sinhronizacija završena'**
  String get syncCompleted;

  /// No description provided for @syncingWithSheets.
  ///
  /// In sr, this message translates to:
  /// **'Sinhronizacija sa Google Sheets...'**
  String get syncingWithSheets;

  /// No description provided for @checkingSheetsHeaders.
  ///
  /// In sr, this message translates to:
  /// **'Proveravamo radne listove i zaglavlja...'**
  String get checkingSheetsHeaders;

  /// No description provided for @loadingData.
  ///
  /// In sr, this message translates to:
  /// **'U toku je učitavanje podataka.'**
  String get loadingData;

  /// No description provided for @savingToSheets.
  ///
  /// In sr, this message translates to:
  /// **'Snimam podatke u Google Sheets…'**
  String get savingToSheets;

  /// No description provided for @waitForSync.
  ///
  /// In sr, this message translates to:
  /// **'Molimo sačekajte dok se sinhronizacija ne završi.'**
  String get waitForSync;

  /// No description provided for @sessionExpired.
  ///
  /// In sr, this message translates to:
  /// **'Sesija je istekla. Prijavite se ponovo da biste nastavili.'**
  String get sessionExpired;

  /// No description provided for @authError.
  ///
  /// In sr, this message translates to:
  /// **'Greška pri autentifikaciji Google naloga.'**
  String get authError;

  /// No description provided for @pickerApiKeyNotConfigured.
  ///
  /// In sr, this message translates to:
  /// **'Google Picker API ključ nije konfigurisan.'**
  String get pickerApiKeyNotConfigured;

  /// No description provided for @pickerLoadError.
  ///
  /// In sr, this message translates to:
  /// **'Nije moguće učitati Google Picker. Pokušajte ponovo.'**
  String get pickerLoadError;

  /// No description provided for @syncFailed.
  ///
  /// In sr, this message translates to:
  /// **'Neuspešna sinhronizacija sa Google Sheets.'**
  String get syncFailed;

  /// No description provided for @autoConnectFailed.
  ///
  /// In sr, this message translates to:
  /// **'Automatsko povezivanje Google Sheets naloga nije uspelo.'**
  String get autoConnectFailed;

  /// No description provided for @connectFailed.
  ///
  /// In sr, this message translates to:
  /// **'Neuspešno povezivanje sa Google Sheets.'**
  String get connectFailed;

  /// No description provided for @sheetCreatedSuccess.
  ///
  /// In sr, this message translates to:
  /// **'Kreiran je novi Google Sheet ({spreadsheetId}).'**
  String sheetCreatedSuccess(String spreadsheetId);

  /// No description provided for @sheetConnectedSuccess.
  ///
  /// In sr, this message translates to:
  /// **'Google Sheets sinhronizacija aktivirana ({spreadsheetId}).'**
  String sheetConnectedSuccess(String spreadsheetId);

  /// No description provided for @spreadsheetInfo.
  ///
  /// In sr, this message translates to:
  /// **'Spreadsheet ID: '**
  String get spreadsheetInfo;

  /// No description provided for @selected.
  ///
  /// In sr, this message translates to:
  /// **'Odabrano: {name}'**
  String selected(String name);

  /// No description provided for @overviewGreeting.
  ///
  /// In sr, this message translates to:
  /// **'Dobrodošao, paušalac'**
  String get overviewGreeting;

  /// No description provided for @overviewSubtitle.
  ///
  /// In sr, this message translates to:
  /// **'Praćenje prihoda, troškova i limita paušalnog oporezivanja.'**
  String get overviewSubtitle;

  /// No description provided for @total.
  ///
  /// In sr, this message translates to:
  /// **'Ukupno'**
  String get total;

  /// No description provided for @issuedInvoices.
  ///
  /// In sr, this message translates to:
  /// **'Izdati računi'**
  String get issuedInvoices;

  /// No description provided for @expenses.
  ///
  /// In sr, this message translates to:
  /// **'Troškovi'**
  String get expenses;

  /// No description provided for @taxObligations.
  ///
  /// In sr, this message translates to:
  /// **'Obaveze paušala'**
  String get taxObligations;

  /// No description provided for @estimatedNet.
  ///
  /// In sr, this message translates to:
  /// **'Procenjeni neto'**
  String get estimatedNet;

  /// No description provided for @revenueShareByClientYear.
  ///
  /// In sr, this message translates to:
  /// **'Udeo prihoda po klijentima u {year}. godini'**
  String revenueShareByClientYear(String year);

  /// No description provided for @noConnectedClients.
  ///
  /// In sr, this message translates to:
  /// **'Još uvek nema povezanih klijenata.'**
  String get noConnectedClients;

  /// No description provided for @clientLimitWarning.
  ///
  /// In sr, this message translates to:
  /// **'Pazite da pojedinačan klijent ne premaši 60% ukupnih prihoda.'**
  String get clientLimitWarning;

  /// No description provided for @rollingLimit.
  ///
  /// In sr, this message translates to:
  /// **'Limit u poslednjih 12 meseci'**
  String get rollingLimit;

  /// No description provided for @remainingToLimit.
  ///
  /// In sr, this message translates to:
  /// **'Preostalo do limita'**
  String get remainingToLimit;

  /// No description provided for @rollingLimitCap.
  ///
  /// In sr, this message translates to:
  /// **'Ograničenje 12m'**
  String get rollingLimitCap;

  /// No description provided for @periodCovered.
  ///
  /// In sr, this message translates to:
  /// **'Obuhvaćen period: {start} - {end}'**
  String periodCovered(String start, String end);

  /// No description provided for @annualLimit.
  ///
  /// In sr, this message translates to:
  /// **'Godišnji limit'**
  String get annualLimit;

  /// No description provided for @totalLimit.
  ///
  /// In sr, this message translates to:
  /// **'Ukupan limit'**
  String get totalLimit;

  /// No description provided for @monthlyObligations.
  ///
  /// In sr, this message translates to:
  /// **'Mesečne obaveze'**
  String get monthlyObligations;

  /// No description provided for @pensionContribution.
  ///
  /// In sr, this message translates to:
  /// **'PIO doprinos'**
  String get pensionContribution;

  /// No description provided for @healthInsurance.
  ///
  /// In sr, this message translates to:
  /// **'Zdravstveno osiguranje'**
  String get healthInsurance;

  /// No description provided for @taxPrepayment.
  ///
  /// In sr, this message translates to:
  /// **'Akontacija poreza'**
  String get taxPrepayment;

  /// No description provided for @totalMonthly.
  ///
  /// In sr, this message translates to:
  /// **'Ukupno mesečno'**
  String get totalMonthly;

  /// No description provided for @recentActivity.
  ///
  /// In sr, this message translates to:
  /// **'Poslednje aktivnosti'**
  String get recentActivity;

  /// No description provided for @noEntriesYet.
  ///
  /// In sr, this message translates to:
  /// **'Još uvek nema zabeleženih stavki.'**
  String get noEntriesYet;

  /// No description provided for @unknownClient.
  ///
  /// In sr, this message translates to:
  /// **'Nepoznat klijent'**
  String get unknownClient;

  /// No description provided for @filters.
  ///
  /// In sr, this message translates to:
  /// **'Filteri'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In sr, this message translates to:
  /// **'Obriši filtere'**
  String get clearFilters;

  /// No description provided for @year.
  ///
  /// In sr, this message translates to:
  /// **'Godina'**
  String get year;

  /// No description provided for @allYears.
  ///
  /// In sr, this message translates to:
  /// **'Sve godine'**
  String get allYears;

  /// No description provided for @month.
  ///
  /// In sr, this message translates to:
  /// **'Mesec'**
  String get month;

  /// No description provided for @allMonths.
  ///
  /// In sr, this message translates to:
  /// **'Svi meseci'**
  String get allMonths;

  /// No description provided for @client.
  ///
  /// In sr, this message translates to:
  /// **'Klijent'**
  String get client;

  /// No description provided for @allClients.
  ///
  /// In sr, this message translates to:
  /// **'Svi klijenti'**
  String get allClients;

  /// No description provided for @invoices.
  ///
  /// In sr, this message translates to:
  /// **'Izdati računi'**
  String get invoices;

  /// No description provided for @noDataYet.
  ///
  /// In sr, this message translates to:
  /// **'Još uvek nema podataka. Dodajte novu stavku.'**
  String get noDataYet;

  /// No description provided for @clients.
  ///
  /// In sr, this message translates to:
  /// **'Klijenti'**
  String get clients;

  /// No description provided for @newClient.
  ///
  /// In sr, this message translates to:
  /// **'Novi klijent'**
  String get newClient;

  /// No description provided for @clientLimitNote.
  ///
  /// In sr, this message translates to:
  /// **'Vodite računa da nijedan klijent ne premaši 60% ukupnih prihoda.'**
  String get clientLimitNote;

  /// No description provided for @noClientsYet.
  ///
  /// In sr, this message translates to:
  /// **'Još uvek nema klijenata.'**
  String get noClientsYet;

  /// No description provided for @addFirstClient.
  ///
  /// In sr, this message translates to:
  /// **'Dodaj prvog klijenta'**
  String get addFirstClient;

  /// No description provided for @pibLabel.
  ///
  /// In sr, this message translates to:
  /// **'PIB: '**
  String get pibLabel;

  /// No description provided for @pibNotAvailable.
  ///
  /// In sr, this message translates to:
  /// **'N/A'**
  String get pibNotAvailable;

  /// No description provided for @clientStats.
  ///
  /// In sr, this message translates to:
  /// **'Udeo: {percent}% · Računi: {invoiceCount} · {amount}'**
  String clientStats(String percent, int invoiceCount, String amount);

  /// No description provided for @profileHeading.
  ///
  /// In sr, this message translates to:
  /// **'Paušal profil'**
  String get profileHeading;

  /// No description provided for @profileHelperText.
  ///
  /// In sr, this message translates to:
  /// **'Ažurirajte podatke o firmi i paušalu. Podaci o firmi se pojavljuju na generisanim fakturama.'**
  String get profileHelperText;

  /// No description provided for @companyData.
  ///
  /// In sr, this message translates to:
  /// **'Podaci o firmi'**
  String get companyData;

  /// No description provided for @companyName.
  ///
  /// In sr, this message translates to:
  /// **'Naziv firme'**
  String get companyName;

  /// No description provided for @companyShortName.
  ///
  /// In sr, this message translates to:
  /// **'Skraćeni naziv (opciono)'**
  String get companyShortName;

  /// No description provided for @responsiblePerson.
  ///
  /// In sr, this message translates to:
  /// **'Odgovorno lice'**
  String get responsiblePerson;

  /// No description provided for @pib.
  ///
  /// In sr, this message translates to:
  /// **'PIB'**
  String get pib;

  /// No description provided for @address.
  ///
  /// In sr, this message translates to:
  /// **'Adresa'**
  String get address;

  /// No description provided for @accountNumber.
  ///
  /// In sr, this message translates to:
  /// **'Broj računa'**
  String get accountNumber;

  /// No description provided for @taxData.
  ///
  /// In sr, this message translates to:
  /// **'Poreski podaci paušala'**
  String get taxData;

  /// No description provided for @city.
  ///
  /// In sr, this message translates to:
  /// **'Grad'**
  String get city;

  /// No description provided for @monthlyPension.
  ///
  /// In sr, this message translates to:
  /// **'PIO doprinos (mesečno)'**
  String get monthlyPension;

  /// No description provided for @monthlyHealth.
  ///
  /// In sr, this message translates to:
  /// **'Zdravstveno osiguranje (mesečno)'**
  String get monthlyHealth;

  /// No description provided for @monthlyTaxPrepayment.
  ///
  /// In sr, this message translates to:
  /// **'Akontacija poreza (mesečno)'**
  String get monthlyTaxPrepayment;

  /// No description provided for @annualLimitLabel.
  ///
  /// In sr, this message translates to:
  /// **'Godišnji limit prihoda'**
  String get annualLimitLabel;

  /// No description provided for @rollingLimitLabel.
  ///
  /// In sr, this message translates to:
  /// **'Limit u poslednjih 12 meseci'**
  String get rollingLimitLabel;

  /// No description provided for @additionalTaxRate.
  ///
  /// In sr, this message translates to:
  /// **'Dodatni porez (u %)'**
  String get additionalTaxRate;

  /// No description provided for @dataSaved.
  ///
  /// In sr, this message translates to:
  /// **'Podaci sačuvani'**
  String get dataSaved;

  /// No description provided for @editEntry.
  ///
  /// In sr, this message translates to:
  /// **'Izmena stavke'**
  String get editEntry;

  /// No description provided for @newEntry.
  ///
  /// In sr, this message translates to:
  /// **'Nova stavka'**
  String get newEntry;

  /// No description provided for @income.
  ///
  /// In sr, this message translates to:
  /// **'Prihod'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In sr, this message translates to:
  /// **'Trošak'**
  String get expense;

  /// No description provided for @invoiceNumber.
  ///
  /// In sr, this message translates to:
  /// **'Broj fakture'**
  String get invoiceNumber;

  /// No description provided for @invoiceNumberHint.
  ///
  /// In sr, this message translates to:
  /// **'npr. 10-2025'**
  String get invoiceNumberHint;

  /// No description provided for @enterInvoiceNumber.
  ///
  /// In sr, this message translates to:
  /// **'Unesite broj fakture'**
  String get enterInvoiceNumber;

  /// No description provided for @invoiceDescription.
  ///
  /// In sr, this message translates to:
  /// **'Opis fakture'**
  String get invoiceDescription;

  /// No description provided for @expenseName.
  ///
  /// In sr, this message translates to:
  /// **'Naziv troška'**
  String get expenseName;

  /// No description provided for @enterName.
  ///
  /// In sr, this message translates to:
  /// **'Unesite naziv'**
  String get enterName;

  /// No description provided for @invoiceItems.
  ///
  /// In sr, this message translates to:
  /// **'Stavke fakture'**
  String get invoiceItems;

  /// No description provided for @addItem.
  ///
  /// In sr, this message translates to:
  /// **'Dodaj stavku'**
  String get addItem;

  /// No description provided for @totalFormatted.
  ///
  /// In sr, this message translates to:
  /// **'Ukupno: {amount}'**
  String totalFormatted(String amount);

  /// No description provided for @selectClientForInvoice.
  ///
  /// In sr, this message translates to:
  /// **'Odaberite klijenta za fakturu'**
  String get selectClientForInvoice;

  /// No description provided for @addAtLeastOneItem.
  ///
  /// In sr, this message translates to:
  /// **'Dodajte bar jednu stavku sa cenom i količinom.'**
  String get addAtLeastOneItem;

  /// No description provided for @enterInvoiceNumberError.
  ///
  /// In sr, this message translates to:
  /// **'Unesite broj fakture.'**
  String get enterInvoiceNumberError;

  /// No description provided for @totalAmount.
  ///
  /// In sr, this message translates to:
  /// **'Ukupan iznos'**
  String get totalAmount;

  /// No description provided for @autoCalculated.
  ///
  /// In sr, this message translates to:
  /// **'Automatski se računa na osnovu stavki'**
  String get autoCalculated;

  /// No description provided for @enterAmountGreaterThanZero.
  ///
  /// In sr, this message translates to:
  /// **'Unesite iznos veći od nule'**
  String get enterAmountGreaterThanZero;

  /// No description provided for @date.
  ///
  /// In sr, this message translates to:
  /// **'Datum'**
  String get date;

  /// No description provided for @selectDate.
  ///
  /// In sr, this message translates to:
  /// **'Izaberi datum'**
  String get selectDate;

  /// No description provided for @noteOptional.
  ///
  /// In sr, this message translates to:
  /// **'Napomena (opciono)'**
  String get noteOptional;

  /// No description provided for @searchClients.
  ///
  /// In sr, this message translates to:
  /// **'Pretraga klijenata'**
  String get searchClients;

  /// No description provided for @noClientsForCriteria.
  ///
  /// In sr, this message translates to:
  /// **'Nema klijenata za zadati kriterijum.'**
  String get noClientsForCriteria;

  /// No description provided for @invoiceItem.
  ///
  /// In sr, this message translates to:
  /// **'Stavka {index}'**
  String invoiceItem(int index);

  /// No description provided for @removeItem.
  ///
  /// In sr, this message translates to:
  /// **'Ukloni stavku'**
  String get removeItem;

  /// No description provided for @itemDescription.
  ///
  /// In sr, this message translates to:
  /// **'Opis stavke'**
  String get itemDescription;

  /// No description provided for @enterItemDescription.
  ///
  /// In sr, this message translates to:
  /// **'Unesite opis stavke'**
  String get enterItemDescription;

  /// No description provided for @unitOfMeasure.
  ///
  /// In sr, this message translates to:
  /// **'Jedinica mere'**
  String get unitOfMeasure;

  /// No description provided for @workHour.
  ///
  /// In sr, this message translates to:
  /// **'Radni sat'**
  String get workHour;

  /// No description provided for @piece.
  ///
  /// In sr, this message translates to:
  /// **'Komad'**
  String get piece;

  /// No description provided for @quantity.
  ///
  /// In sr, this message translates to:
  /// **'Količina'**
  String get quantity;

  /// No description provided for @enterQuantity.
  ///
  /// In sr, this message translates to:
  /// **'Unesite količinu'**
  String get enterQuantity;

  /// No description provided for @pricePerUnit.
  ///
  /// In sr, this message translates to:
  /// **'Cena po jedinici'**
  String get pricePerUnit;

  /// No description provided for @enterPrice.
  ///
  /// In sr, this message translates to:
  /// **'Unesite cenu'**
  String get enterPrice;

  /// No description provided for @itemAmount.
  ///
  /// In sr, this message translates to:
  /// **'Iznos stavke: {total}'**
  String itemAmount(String total);

  /// No description provided for @editClient.
  ///
  /// In sr, this message translates to:
  /// **'Izmena klijenta'**
  String get editClient;

  /// No description provided for @clientName.
  ///
  /// In sr, this message translates to:
  /// **'Naziv klijenta'**
  String get clientName;

  /// No description provided for @enterClientName.
  ///
  /// In sr, this message translates to:
  /// **'Unesite naziv klijenta'**
  String get enterClientName;

  /// No description provided for @actions.
  ///
  /// In sr, this message translates to:
  /// **'Radnje'**
  String get actions;

  /// No description provided for @print.
  ///
  /// In sr, this message translates to:
  /// **'Štampa'**
  String get print;

  /// No description provided for @pdfSend.
  ///
  /// In sr, this message translates to:
  /// **'PDF / Pošalji'**
  String get pdfSend;

  /// No description provided for @addClientBeforePrint.
  ///
  /// In sr, this message translates to:
  /// **'Dodajte klijenta pre štampe fakture.'**
  String get addClientBeforePrint;

  /// No description provided for @addClientBeforeSend.
  ///
  /// In sr, this message translates to:
  /// **'Dodajte klijenta pre slanja fakture.'**
  String get addClientBeforeSend;

  /// No description provided for @invoiceDetail.
  ///
  /// In sr, this message translates to:
  /// **'Faktura {number}'**
  String invoiceDetail(String number);

  /// No description provided for @invoiceShareText.
  ///
  /// In sr, this message translates to:
  /// **'Faktura {invoiceNumber} za {clientName} iznosi {amount}.\nUplata na račun: {accountNumber}.'**
  String invoiceShareText(
    String invoiceNumber,
    String clientName,
    String amount,
    String accountNumber,
  );

  /// No description provided for @fabNewEntry.
  ///
  /// In sr, this message translates to:
  /// **'Nova stavka'**
  String get fabNewEntry;

  /// No description provided for @fabNewClient.
  ///
  /// In sr, this message translates to:
  /// **'Novi klijent'**
  String get fabNewClient;

  /// No description provided for @enterValue.
  ///
  /// In sr, this message translates to:
  /// **'Unesite naziv'**
  String get enterValue;

  /// No description provided for @enterNumberGreaterOrEqualZero.
  ///
  /// In sr, this message translates to:
  /// **'Unesite broj veći ili jednak nuli'**
  String get enterNumberGreaterOrEqualZero;

  /// No description provided for @sheetInfo.
  ///
  /// In sr, this message translates to:
  /// **'Sheetovi: {expensesSheet} (troškovi), {clientsSheet} (klijenti), {profileSheet} (profil)'**
  String sheetInfo(
    String expensesSheet,
    String clientsSheet,
    String profileSheet,
  );

  /// No description provided for @connectedAsEmail.
  ///
  /// In sr, this message translates to:
  /// **'Povezano kao {email}'**
  String connectedAsEmail(String email);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
