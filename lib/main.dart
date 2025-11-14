import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'firebase_options.dart';
import 'services/google_auth_service.dart';
import 'services/google_picker_service.dart';
import 'services/google_sheets_service.dart';
import 'storage/sync_metadata_storage.dart';

const Color _pastelBlue = Color(0xFF8AAEF2);
const Color _pastelBlueDark = Color(0xFF4F6FDB);
const Color _pastelBlueLight = Color(0xFFE6ECFF);
const String? kGoogleWebClientId =
    "97156095733-42r8nl0j9krm0rr4ak8nb66foghu2ssf.apps.googleusercontent.com";
const String kGooglePickerApiKey = String.fromEnvironment(
  'GOOGLE_PICKER_API_KEY',
  defaultValue: 'AIzaSyCc2OSeq2OMtoFTCsEwV_ujObWoGbgAUnA',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    SharedPreferencesPlugin.registerWith(null);
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  // final firebaseInitialized = await _initializeFirebase();

  // FirebaseAnalyticsObserver? analyticsObserver;
  // if (firebaseInitialized) {
  // final analytics = FirebaseAnalytics.instance;
  //   analyticsObserver = FirebaseAnalyticsObserver(analytics: analytics);
  //   unawaited(analytics.logAppOpen());
  // }

  runApp(
    PausalApp(
      // analyticsObserver: analyticsObserver,
    ),
  );
}

class PausalApp extends StatelessWidget {
  const PausalApp({
    super.key,
    // required this.analyticsObserver,
  });

  // final FirebaseAnalyticsObserver? analyticsObserver;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paušal kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _pastelBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/app': (context) => const PausalHome(),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
      },
      // navigatorObservers: [
      //   if (analyticsObserver != null) analyticsObserver!,
      // ],
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _openPrivacyPolicy(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushNamed('/privacy_policy');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isWide = mediaQuery.size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: () => _openPrivacyPolicy(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
            child: const Text('Privacy Policy'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 24,
          vertical: 32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paušal kalkulator',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Digitalni asistent za paušalno oporezovane preduzetnike koji razvija Finna Cons.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/app');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Pokreni aplikaciju'),
                    ),
                    OutlinedButton(
                      onPressed: () => _openPrivacyPolicy(context),
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Šta aplikacija radi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        _LandingBullet(
                          icon: Icons.dashboard_customize,
                          title: 'Pregled poslovanja',
                          description:
                              'Automatski izračunava promet, troškove, neto prihod i poreske obaveze po osnovu paušalnog oporezivanja.',
                        ),
                        _LandingBullet(
                          icon: Icons.people_outline,
                          title: 'Upravljanje klijentima',
                          description:
                              'Pratite prihod po klijentu, evidentirajte ugovore i vodite računa o propisanim limitima.',
                        ),
                        _LandingBullet(
                          icon: Icons.receipt_long_outlined,
                          title: 'Fakturisanje',
                          description:
                              'Kreirajte PDF fakture u skladu sa lokalnim propisima i delite ih direktno iz aplikacije.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kako funkcioniše integracija sa Google-om',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        _LandingBullet(
                          icon: Icons.login,
                          title: 'Google Sign-In',
                          description:
                              'Prijava se koristi isključivo za autentifikaciju korisnika i pristup njihovom Google Sheets dokumentu koji sami odaberu.',
                        ),
                        _LandingBullet(
                          icon: Icons.cloud_sync_outlined,
                          title: 'Sinhronizacija podataka',
                          description:
                              'Sav unos (prihodi, troškovi, klijenti i profili) čuva se u vašem Google Sheets dokumentu. Aplikacija ne kopira, ne skladišti i ne deli podatke van vašeg naloga.',
                        ),
                        _LandingBullet(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Transparentnost',
                          description:
                              'Pristup podacima postoji samo dok ste prijavljeni. Možete se odjaviti u bilo kom trenutku i zadržavate punu kontrolu nad svojim dokumentima.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zašto paušalci biraju Finaccons',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Paušal kalkulator održava Finaccons tim i razvijen je uz praksu rada sa paušalcima iz različitih delatnosti. Cilj je da finansijski podaci budu transparentni, precizni i uvek dostupni.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kontakt',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          'office@finaccons.rs',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Za podršku ili pitanja o obradi podataka, pišite nam u bilo kom trenutku.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'Finaccons ${DateTime.now().year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politika privatnosti'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/app'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
            child: const Text('Pokreni aplikaciju'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Politika privatnosti – Paušal kalkulator',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ova politika privatnosti objašnjava kako Paušal kalkulator koristi i štiti podatke kada se korisnik prijavi putem Google naloga i poveže svoj Google Sheets dokument radi obračuna i praćenja poslovanja.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // 1) Podaci kojima pristupamo
                const Text(
                  'Podaci kojima pristupamo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const _LandingBullet(
                  icon: Icons.person_outline,
                  title: 'Google nalog (openid)',
                  description:
                      'Koristimo “openid” dozvolu kako bismo vas bezbedno prijavili u aplikaciju i povezali vaš nalog sa jedinstvenim identifikatorom koji dobijamo od Google-a. Ne koristimo i ne čuvamo vašu e-mail adresu za potrebe aplikacije.',
                ),
                const _LandingBullet(
                  icon: Icons.table_chart_outlined,
                  title: 'Google Drive / Sheets fajl koji izaberete',
                  description:
                      'Aplikacija koristi “drive.file” dozvolu kako bi vam omogućila da izaberete konkretan Google Sheets fajl. Paušal kalkulator čita i upisuje podatke isključivo u taj fajl (npr. prihodi, troškovi, klijenti), i nema pristup drugim dokumentima na vašem Google Drive nalogu.',
                ),
                const SizedBox(height: 24),

                // 2) Google API dozvole
                const Text(
                  'Google API dozvole (scopes)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Paušal kalkulator koristi samo minimalne dozvole neophodne za rad aplikacije:\n\n'
                  '• openid – za bezbednu prijavu korisnika.\n'
                  '• https://www.googleapis.com/auth/drive.file – za izbor i obradu konkretnih fajlova na Google Drive-u koje sami odaberete.\n\n'
                  'Ne koristimo sledeće dozvole: “email”, “spreadsheets” niti bilo koje druge osetljive ili ograničene Google API dozvole koje nisu neophodne za funkcionisanje aplikacije.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // 3) Kako koristimo podatke
                const Text(
                  'Kako koristimo podatke',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pristup Google nalogu i odabranom Google Sheets dokumentu koristimo isključivo da bismo:\n\n'
                  '• omogućili prijavu u aplikaciju,\n'
                  '• pročitali podatke iz odabranog Sheets fajla radi obračuna i prikaza u aplikaciji,\n'
                  '• upisali nove unose i izmene u taj isti fajl radi ažurnog vođenja evidencije.\n\n'
                  'Ne koristimo vaše Google podatke za oglašavanje, marketing ili pravljenje korisničkih profila. '
                  'Ne prodajemo i ne iznajmljujemo vaše podatke trećim stranama i ne koristimo podatke iz Google Drive/Sheets fajlova za obučavanje opštih AI/ML modela.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // 4) Čuvanje, zaštita i deljenje
                const Text(
                  'Čuvanje, zaštita i deljenje podataka',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sadržaj vaših Google Sheets dokumenata ostaje u okviru vašeg Google naloga. Aplikacija te podatke čita “na zahtev” i, po potrebi, kratkotrajno kešira radi performansi. '
                  'Takvi podaci se čuvaju najkraće moguće vreme i zaštićeni su odgovarajućim tehničkim merama (HTTPS/TLS, kontrola pristupa itd.).\n\n'
                  'Podatke ne delimo sa trećim stranama osim sa pouzdanim tehničkim provajderima (npr. hosting), i to isključivo u meri u kojoj je neophodno za rad aplikacije, uz ugovornu obavezu zaštite podataka.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // 5) Vaša prava i brisanje
                const Text(
                  'Vaša prava i brisanje podataka',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pristup aplikaciji možete opozvati u bilo kom trenutku preko stranice vašeg Google naloga:\n'
                  'https://myaccount.google.com/permissions\n\n'
                  'Takođe, možete nam se obratiti ukoliko želite da obrišemo podatke koji se čuvaju u okviru same aplikacije (npr. lokalne konfiguracije). '
                  'Nakon potvrde identiteta, obrišaćemo ili anonimizovati podatke, osim onih koje smo zakonski obavezni da zadržimo (npr. knjigovodstvena evidencija).',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // 6) Kontakt
                const Text(
                  'Pitanja i kontakt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ako imate pitanja u vezi sa politikom privatnosti ili načinom na koji aplikacija obrađuje podatke, možete nas kontaktirati na:',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  'office@finaccons.rs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // 7) Datum
                Text(
                  'Poslednje ažuriranje: 14.11.2025.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingBullet extends StatelessWidget {
  const _LandingBullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PausalHome extends StatefulWidget {
  const PausalHome({super.key});

  @override
  State<PausalHome> createState() => _PausalHomeState();
}

enum _SheetSyncTarget { entries, clients, profile }

class _PausalHomeState extends State<PausalHome> {
  int _currentIndex = 0;

  String? _spreadsheetId;
  String _expensesSheetName = 'Expenses';
  String _clientsSheetName = 'Clients';
  String _profileSheetName = 'Profile';
  String? _googleUserEmail;
  bool _isConnecting = true;

  bool get _isConnected => _sheetsService != null;

  bool _ensureConnected() {
    if (_isConnected) {
      return true;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Povežite Google Sheets pre nego što dodate podatke.'),
        ),
      );
    }
    return false;
  }

  String? _extractSpreadsheetId(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final urlPattern = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final urlMatch = urlPattern.firstMatch(trimmed);
    if (urlMatch != null) {
      return urlMatch.group(1);
    }
    final idPattern = RegExp(r'^[a-zA-Z0-9-_]{10,}$');
    if (idPattern.hasMatch(trimmed)) {
      return trimmed;
    }
    return null;
  }

  CompanyProfile _companyProfile = const CompanyProfile(
    name: '',
    shortName: '',
    responsiblePerson: '',
    pib: '',
    address: '',
    accountNumber: '',
  );

  List<Client> _clients = [];

  List<LedgerEntry> _entries = [];

  TaxProfile _profile = const TaxProfile(
    city: '',
    monthlyPension: 0,
    monthlyHealth: 0,
    monthlyTaxPrepayment: 0,
    annualLimit: 6000000,
    rollingLimit: 8000000,
    additionalTaxRate: 0,
  );

  final GoogleAuthService _authService = GoogleAuthService(
    webClientId: kGoogleWebClientId,
  );
  GoogleSheetsService? _sheetsService;
  GoogleUser? _googleUser;
  bool _isSyncing = false;
  bool _isUploading = false;
  final Set<_SheetSyncTarget> _pendingSyncTargets = <_SheetSyncTarget>{};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.microtask(_restoreSessionSilently);
    }
  }

  @override
  void dispose() {
    _sheetsService?.close();
    super.dispose();
  }

  void _addEntry(LedgerEntry entry) {
    if (!_ensureConnected()) return;
    setState(() {
      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
    });
    _pushDataToSheets({_SheetSyncTarget.entries});
  }

  void _updateEntry(LedgerEntry updated) {
    if (!_ensureConnected()) return;
    setState(() {
      final index = _entries.indexWhere((entry) => entry.id == updated.id);
      if (index != -1) {
        _entries[index] = updated;
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
    });
    _pushDataToSheets({_SheetSyncTarget.entries});
  }

  void _removeEntry(String id) {
    if (!_ensureConnected()) return;
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
    _pushDataToSheets({_SheetSyncTarget.entries});
  }

  void _updateProfiles({
    TaxProfile? taxProfile,
    CompanyProfile? companyProfile,
  }) {
    if (taxProfile == null && companyProfile == null) {
      return;
    }
    if (!_ensureConnected()) return;
    setState(() {
      if (taxProfile != null) {
        _profile = taxProfile;
      }
      if (companyProfile != null) {
        _companyProfile = companyProfile;
      }
    });
    _pushDataToSheets({_SheetSyncTarget.profile});
  }

  void _updateBothProfiles(
    TaxProfile taxProfile,
    CompanyProfile companyProfile,
  ) {
    _updateProfiles(taxProfile: taxProfile, companyProfile: companyProfile);
  }

  void _addClient(Client client) {
    if (!_ensureConnected()) return;
    setState(() {
      _clients.add(client);
      _clients.sort((a, b) => a.name.compareTo(b.name));
    });
    _pushDataToSheets({_SheetSyncTarget.clients});
  }

  void _updateClient(Client updated) {
    if (!_ensureConnected()) return;
    setState(() {
      final index = _clients.indexWhere((client) => client.id == updated.id);
      if (index != -1) {
        _clients[index] = updated;
        _clients.sort((a, b) => a.name.compareTo(b.name));
      }
    });
    _pushDataToSheets({_SheetSyncTarget.clients});
  }

  void _removeClient(String id) {
    if (!_ensureConnected()) return;
    setState(() {
      _clients.removeWhere((client) => client.id == id);
      for (var i = 0; i < _entries.length; i++) {
        final entry = _entries[i];
        if (entry.clientId == id) {
          _entries[i] = entry.copyWith(clientId: null);
        }
      }
    });
    _pushDataToSheets({_SheetSyncTarget.clients, _SheetSyncTarget.entries});
  }

  void _pushDataToSheets(Set<_SheetSyncTarget> targets) {
    if (targets.isEmpty) {
      return;
    }
    _pendingSyncTargets.addAll(targets);
    _uploadPendingSheets();
  }

  void _uploadPendingSheets() {
    final service = _sheetsService;
    if (service == null || _pendingSyncTargets.isEmpty || _isUploading) {
      return;
    }

    final targetsToUpload = Set<_SheetSyncTarget>.from(_pendingSyncTargets);
    _pendingSyncTargets.clear();
    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    } else {
      _isUploading = true;
    }
    Future.microtask(() async {
      try {
        await service.uploadAll(
          entries: targetsToUpload.contains(_SheetSyncTarget.entries)
              ? _entries.map((entry) => entry.toJson()).toList()
              : null,
          clients: targetsToUpload.contains(_SheetSyncTarget.clients)
              ? _clients.map((client) => client.toJson()).toList()
              : null,
          companyProfile: targetsToUpload.contains(_SheetSyncTarget.profile)
              ? _companyProfile.toJson()
              : null,
          taxProfile: targetsToUpload.contains(_SheetSyncTarget.profile)
              ? _profile.toJson()
              : null,
        );
      } catch (error, stack) {
        debugPrint('Google Sheets sync failed: $error');
        debugPrint('$stack');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Neuspešna sinhronizacija sa Google Sheets.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        } else {
          _isUploading = false;
        }
        if (_pendingSyncTargets.isNotEmpty) {
          _uploadPendingSheets();
        }
      }
    });
  }

  Future<void> _restoreSessionSilently() async {
    SyncMetadata? metadata;
    try {
      metadata = await SyncMetadataStorage.load();
    } catch (error, stack) {
      debugPrint('Failed to load sync metadata: $error');
      debugPrint('$stack');
    }

    if (!mounted) {
      return;
    }

    if (metadata == null) {
      setState(() {
        _isConnecting = false;
      });
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    _spreadsheetId = metadata.spreadsheetId;
    _expensesSheetName = metadata.expensesSheet;
    _clientsSheetName = metadata.clientsSheet;
    _profileSheetName = metadata.profileSheet;

    try {
      final user = await _authService.signInSilently().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (user == null) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      final client = await _authService.getAuthenticatedClient().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (client == null) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      final service = GoogleSheetsService(
        client: client,
        spreadsheetId: _spreadsheetId!,
        expensesSheet: _expensesSheetName,
        clientsSheet: _clientsSheetName,
        profileSheet: _profileSheetName,
      );

      await service.ensureStructure();

      final remoteEntries = await service.fetchEntries();
      final remoteClients = await service.fetchClients();
      final remoteProfiles = await service.fetchProfiles();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _googleUser = user;
        _googleUserEmail = user.email;
        _sheetsService = service;
        _entries =
            remoteEntries
                .map(
                  (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        _clients =
            remoteClients
                .map((map) => Client.fromJson(Map<String, dynamic>.from(map)))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        final companyData = remoteProfiles['company'];
        if (companyData != null && companyData.isNotEmpty) {
          _companyProfile = CompanyProfile.fromJson(
            Map<String, dynamic>.from(companyData),
          );
        }
        final taxData = remoteProfiles['tax'];
        if (taxData != null && taxData.isNotEmpty) {
          _profile = TaxProfile.fromJson(Map<String, dynamic>.from(taxData));
        }
      });
    } catch (error, stack) {
      debugPrint('Silent session restore failed: $error');
      debugPrint('$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Automatsko povezivanje Google Sheets naloga nije uspelo.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Client? _findClient(String? id) {
    if (id == null) {
      return null;
    }
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (_) {
      return null;
    }
  }

  void _openEntrySheet({LedgerEntry? entry}) {
    if (!_ensureConnected()) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AddEntrySheet(
          initialEntry: entry,
          onSubmit: entry == null ? _addEntry : _updateEntry,
          onDelete: entry == null ? null : () => _removeEntry(entry.id),
          clients: _clients,
          existingEntries: _entries,
          onCreateClient: _addClient,
        );
      },
    );
  }

  void _openClientSheet({Client? client}) {
    if (!_ensureConnected()) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AddClientSheet(
          initialClient: client,
          onSubmit: client == null ? _addClient : _updateClient,
          onDelete: client == null ? null : () => _removeClient(client.id),
        );
      },
    );
  }

  Future<void> _printInvoice(LedgerEntry entry) async {
    final client = _findClient(entry.clientId);
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodajte klijenta pre štampe fakture.')),
      );
      return;
    }

    final pdfData = await _buildInvoicePdf(
      entry,
      client,
      _companyProfile,
      _profile,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdfData,
      name: '${_sanitizeFileName(entry.title)}.pdf',
    );
  }

  Future<void> _shareInvoice(LedgerEntry entry) async {
    final client = _findClient(entry.clientId);
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodajte klijenta pre slanja fakture.')),
      );
      return;
    }

    final pdfData = await _buildInvoicePdf(
      entry,
      client,
      _companyProfile,
      _profile,
    );
    final fileName = '${_sanitizeFileName(entry.title)}.pdf';
    final shareFile = XFile.fromData(
      pdfData,
      name: fileName,
      mimeType: 'application/pdf',
    );
    await Share.shareXFiles(
      [shareFile],
      subject: entry.title,
      text:
          'Faktura ${entry.invoiceNumber?.isNotEmpty == true ? entry.invoiceNumber : entry.title} za ${client.name} iznosi ${formatCurrency(entry.amount)}.\nUplata na račun: ${_companyProfile.accountNumber}.',
    );
  }

  Future<void> _connectGoogleSheets() async {
    if (_isSyncing) {
      return;
    }
    setState(() {
      _isSyncing = true;
      _isConnecting = true;
    });
    GoogleSheetsService? service;
    try {
      final user = await _authService.signIn();
      if (user == null) {
        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }

      final config = await _promptForSpreadsheetConfig();
      if (config == null) {
        await _authService.signOut();
        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }
      final client = await _authService.getAuthenticatedClient().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (client == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Greška pri autentifikaciji Google naloga.'),
            ),
          );
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }

      _sheetsService?.close();
      final expensesSheet = config.expensesSheet;
      final clientsSheet = config.clientsSheet;
      final profileSheet = config.profileSheet;
      final spreadsheetId = config.createNew
          ? await GoogleSheetsService.createSpreadsheet(
              client: client,
              title: config.spreadsheetTitle!,
              expensesSheet: expensesSheet,
              clientsSheet: clientsSheet,
              profileSheet: profileSheet,
            )
          : config.spreadsheetId!;

      service = GoogleSheetsService(
        client: client,
        spreadsheetId: spreadsheetId,
        expensesSheet: expensesSheet,
        clientsSheet: clientsSheet,
        profileSheet: profileSheet,
      );

      await service.ensureStructure();

      final remoteEntries = await service.fetchEntries();
      final remoteClients = await service.fetchClients();
      final remoteProfiles = await service.fetchProfiles();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _entries =
            remoteEntries
                .map(
                  (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        _clients =
            remoteClients
                .map((map) => Client.fromJson(Map<String, dynamic>.from(map)))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        _googleUser = user;
        _googleUserEmail = user.email;
        _sheetsService = service;
        _spreadsheetId = spreadsheetId;
        _expensesSheetName = expensesSheet;
        _clientsSheetName = clientsSheet;
        _profileSheetName = profileSheet;
        _isSyncing = false;
        _isConnecting = false;
        final companyData = remoteProfiles['company'];
        if (companyData != null && companyData.isNotEmpty) {
          _companyProfile = CompanyProfile.fromJson(
            Map<String, dynamic>.from(companyData),
          );
        }
        final taxData = remoteProfiles['tax'];
        if (taxData != null && taxData.isNotEmpty) {
          _profile = TaxProfile.fromJson(Map<String, dynamic>.from(taxData));
        }
      });
      await SyncMetadataStorage.save(
        spreadsheetId: spreadsheetId,
        expensesSheet: expensesSheet,
        clientsSheet: clientsSheet,
        profileSheet: profileSheet,
      );
      if (config.createNew) {
        _pushDataToSheets(_SheetSyncTarget.values.toSet());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            config.createNew
                ? 'Kreiran je novi Google Sheet (${spreadsheetId}).'
                : 'Google Sheets sinhronizacija aktivirana (${spreadsheetId}).',
          ),
        ),
      );
    } catch (error, stack) {
      debugPrint('Failed to connect Google Sheets: $error');
      debugPrint('$stack');
      service?.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Neuspešno povezivanje sa Google Sheets.'),
          ),
        );
        setState(() {
          _isSyncing = false;
          _isConnecting = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      } else {
        _isConnecting = false;
      }
    }
  }

  Future<void> _disconnectGoogleSheets() async {
    // _sheetsService?.close();
    await _authService.signOut();
    await SyncMetadataStorage.clear();
    setState(() {
      _googleUser = null;
      _googleUserEmail = null;
      _sheetsService = null;
      _isConnecting = false;
      _isSyncing = false;
      _spreadsheetId = null;
      _expensesSheetName = 'Expenses';
      _clientsSheetName = 'Clients';
      _profileSheetName = 'Profile';
      _entries = [];
      _clients = [];
    });
  }

  Future<_SpreadsheetConfig?> _promptForSpreadsheetConfig() async {
    final idController = TextEditingController(text: _spreadsheetId ?? '');
    final titleController = TextEditingController(text: 'Paušal kalkulator');
    final expensesController = TextEditingController(text: _expensesSheetName);
    final clientsController = TextEditingController(text: _clientsSheetName);
    final profileController = TextEditingController(text: _profileSheetName);
    final formKey = GlobalKey<FormState>();
    bool createNew = _spreadsheetId == null || _spreadsheetId!.isEmpty;
    String? pickedSpreadsheetName =
        (_spreadsheetId != null && _spreadsheetId!.isNotEmpty)
        ? _spreadsheetId
        : null;
    bool isPickingSpreadsheet = false;
    var isDialogMounted = true;

    final result =
        await showDialog<_SpreadsheetConfig>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                Future<void> launchPicker() async {
                  if (!kIsWeb) {
                    return;
                  }
                  if (kGooglePickerApiKey.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google Picker API ključ nije konfigurisan.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  final token = await _authService.getActiveAccessToken();
                  if (token == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Greška pri autentifikaciji Google naloga.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (!isDialogMounted) {
                    return;
                  }
                  setDialogState(() {
                    isPickingSpreadsheet = true;
                  });
                  final pickerService = GooglePickerService(
                    apiKey: kGooglePickerApiKey,
                  );
                  try {
                    final selection = await pickerService.pickSpreadsheet(
                      oauthToken: token,
                    );
                    if (selection != null && isDialogMounted) {
                      setDialogState(() {
                        pickedSpreadsheetName = selection.name;
                        idController.text = selection.id;
                      });
                    }
                  } catch (error, stack) {
                    debugPrint('Failed to open Google Picker: $error');
                    debugPrint('$stack');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nije moguće učitati Google Picker. Pokušajte ponovo.',
                          ),
                        ),
                      );
                    }
                  } finally {
                    if (isDialogMounted) {
                      setDialogState(() {
                        isPickingSpreadsheet = false;
                      });
                    }
                  }
                }

                return AlertDialog(
                  title: const Text('Povezivanje sa Google Sheet-om'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: createNew,
                            title: const Text('Kreiraj novi Google Sheet'),
                            subtitle: const Text(
                              'Aplikacija će automatski kreirati dokument i radne listove.',
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                createNew = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (createNew)
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Naziv dokumenta',
                                hintText: 'Paušal kalkulator',
                              ),
                              validator: (value) {
                                if (!createNew) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite naziv dokumenta';
                                }
                                return null;
                              },
                            )
                          else if (kIsWeb)
                            TextFormField(
                              controller: idController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Google Sheet dokument',
                                hintText: 'Izaberite Google Sheets dokument',
                                helperText: pickedSpreadsheetName == null
                                    ? 'Kliknite na ikonu desno kako biste izabrali dokument.'
                                    : 'Odabrano: $pickedSpreadsheetName',
                                suffixIcon: IconButton(
                                  tooltip: 'Izaberi iz Google Drive-a',
                                  onPressed:
                                      isPickingSpreadsheet ||
                                          kGooglePickerApiKey.isEmpty
                                      ? null
                                      : () {
                                          FocusScope.of(
                                            dialogContext,
                                          ).unfocus();
                                          unawaited(launchPicker());
                                        },
                                  icon: isPickingSpreadsheet
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.folder_open),
                                ),
                              ),
                              onTap:
                                  isPickingSpreadsheet ||
                                      kGooglePickerApiKey.isEmpty
                                  ? null
                                  : () {
                                      FocusScope.of(dialogContext).unfocus();
                                      unawaited(launchPicker());
                                    },
                              validator: (value) {
                                if (createNew) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Izaberite Google Sheet dokument';
                                }
                                return null;
                              },
                            )
                          else
                            TextFormField(
                              controller: idController,
                              decoration: const InputDecoration(
                                labelText: 'Spreadsheet URL ili ID',
                                hintText:
                                    'https://docs.google.com/... ili 1A2B3C...',
                              ),
                              validator: (value) {
                                if (createNew) {
                                  return null;
                                }
                                if (_extractSpreadsheetId(value) == null) {
                                  return 'Unesite pun URL ili ID Google Sheets dokumenta';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: expensesController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za troškove',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: clientsController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za klijente',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: profileController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za profil',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Otkaži'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() != true) {
                          return;
                        }
                        final expensesSheet =
                            expensesController.text.trim().isEmpty
                            ? 'Expenses'
                            : expensesController.text.trim();
                        final clientsSheet =
                            clientsController.text.trim().isEmpty
                            ? 'Clients'
                            : clientsController.text.trim();
                        final profileSheet =
                            profileController.text.trim().isEmpty
                            ? 'Profile'
                            : profileController.text.trim();
                        final parsedId = _extractSpreadsheetId(
                          idController.text,
                        );
                        final config = createNew
                            ? _SpreadsheetConfig(
                                createNew: true,
                                spreadsheetTitle: titleController.text.trim(),
                                expensesSheet: expensesSheet,
                                clientsSheet: clientsSheet,
                                profileSheet: profileSheet,
                              )
                            : _SpreadsheetConfig(
                                createNew: false,
                                spreadsheetId: parsedId!,
                                expensesSheet: expensesSheet,
                                clientsSheet: clientsSheet,
                                profileSheet: profileSheet,
                              );
                        Navigator.of(dialogContext).pop(config);
                      },
                      child: const Text('Poveži'),
                    ),
                  ],
                );
              },
            );
          },
        ).whenComplete(() {
          isDialogMounted = false;
        });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideLayout = mediaQuery.size.width >= 900;
    final isRailExtended = mediaQuery.size.width >= 1200;
    final theme = Theme.of(context);

    final screens = _isConnected
        ? [
            OverviewTab(
              entries: _entries,
              profile: _profile,
              clients: _clients,
            ),
            LedgerTab(
              entries: _entries,
              clients: _clients,
              onRemove: _removeEntry,
              onEdit: (entry) => _openEntrySheet(entry: entry),
              onShareInvoice: _shareInvoice,
              onPrintInvoice: _printInvoice,
              findClient: _findClient,
            ),
            ClientsTab(
              clients: _clients,
              entries: _entries,
              onAddClient: () => _openClientSheet(),
              onEditClient: (client) => _openClientSheet(client: client),
              onDeleteClient: _removeClient,
            ),
            SettingsTab(
              taxProfile: _profile,
              companyProfile: _companyProfile,
              onProfilesChanged: _updateBothProfiles,
              isConnected: true,
              isSyncing: _isSyncing || _isConnecting,
              spreadsheetId: _spreadsheetId,
              expensesSheet: _expensesSheetName,
              clientsSheet: _clientsSheetName,
              profileSheet: _profileSheetName,
              userEmail: _googleUserEmail,
              onConnectSheets: _connectGoogleSheets,
              onDisconnectSheets: _disconnectGoogleSheets,
            ),
          ]
        : [
            _ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            _ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            _ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            SettingsTab(
              taxProfile: _profile,
              companyProfile: _companyProfile,
              onProfilesChanged: _updateBothProfiles,
              isConnected: false,
              isSyncing: _isSyncing || _isConnecting,
              spreadsheetId: _spreadsheetId,
              expensesSheet: _expensesSheetName,
              clientsSheet: _clientsSheetName,
              profileSheet: _profileSheetName,
              userEmail: _googleUserEmail,
              onConnectSheets: _connectGoogleSheets,
              onDisconnectSheets: _disconnectGoogleSheets,
            ),
          ];

    Widget? floatingActionButton;
    if (_isConnected) {
      if (_currentIndex == 0 || _currentIndex == 1) {
        floatingActionButton = FloatingActionButton.extended(
          onPressed: () => _openEntrySheet(),
          icon: const Icon(Icons.add),
          label: const Text('Nova stavka'),
        );
      } else if (_currentIndex == 2) {
        floatingActionButton = FloatingActionButton.extended(
          onPressed: () => _openClientSheet(),
          icon: const Icon(Icons.person_add),
          label: const Text('Novi klijent'),
        );
      }
    }

    final scaffold = Scaffold(
      body: isWideLayout
          ? Row(
              children: [
                NavigationRail(
                  extended: isRailExtended,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: isRailExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  leading: const SizedBox(height: 8),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Pregled'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Knjiga'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Klijenti'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            )
          : IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: isWideLayout
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Pregled',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Knjiga',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Klijenti',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Profil',
                ),
              ],
            ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: isWideLayout
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );

    return Stack(
      children: [
        scaffold,
        if (_isUploading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                alignment: Alignment.center,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Snimam podatke u Google Sheets…',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Molimo sačekajte dok se sinhronizacija ne završi.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.entries,
    required this.profile,
    required this.clients,
  });

  final List<LedgerEntry> entries;
  final TaxProfile profile;
  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    final invoices = entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final expenses = entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .toList();

    final totalInvoiced = invoices.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final now = DateTime.now();
    final currentYear = DateTime.now().year;
    final totalInvoicedCurrentYear = invoices
        .where((invoice) => invoice.date.year == currentYear)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final trackedMonths = _countTrackedMonths(entries);
    final fixedObligations =
        profile.monthlyFixedContributions *
        (trackedMonths == 0 ? 1 : trackedMonths);

    final taxableBase = (totalInvoiced - totalExpenses).clamp(
      0,
      double.infinity,
    );
    final additionalTax = taxableBase * profile.additionalTaxRate;
    final totalObligations = fixedObligations + additionalTax;
    final netIncome = totalInvoiced - totalExpenses - totalObligations;

    final remainingLimit = (profile.annualLimit - totalInvoicedCurrentYear)
        .clamp(0, double.infinity);
    final limitProgress = profile.annualLimit == 0
        ? 0.0
        : (totalInvoicedCurrentYear / profile.annualLimit).clamp(0.0, 1.0);

    // final now = DateTime.now();
    final DateTime rollingWindowStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 365));
    final totalLast12Months = invoices
        .where((invoice) => invoice.date.isAfter(rollingWindowStart))
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final rollingProgress = profile.rollingLimit == 0
        ? 0.0
        : (totalLast12Months / profile.rollingLimit).clamp(0.0, 1.0);
    final rollingRemaining = (profile.rollingLimit - totalLast12Months).clamp(
      0,
      double.infinity,
    );

    final Map<String, double> clientTotals = {};
    for (final invoice in invoices.where(
      (invoice) => invoice.date.year == currentYear,
    )) {
      final clientId = invoice.clientId;
      if (clientId == null) continue;

      clientTotals.update(
        clientId,
        (value) => value + invoice.amount,
        ifAbsent: () => invoice.amount,
      );
    }
    final totalForShare = totalInvoicedCurrentYear == 0
        ? 1
        : totalInvoicedCurrentYear;
    final clientShares = <_ClientShare>[];
    for (final entry in clientTotals.entries) {
      final client = clients.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Client(
          id: entry.key,
          name: 'Nepoznat klijent',
          pib: '',
          address: '',
        ),
      );
      final share = entry.value / totalForShare;
      clientShares.add(
        _ClientShare(client: client, amount: entry.value, share: share),
      );
    }
    clientShares.sort((a, b) => b.share.compareTo(a.share));

    final latestEntries = entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    Client? resolveClient(String? id) {
      if (id == null) return null;
      try {
        return clients.firstWhere((client) => client.id == id);
      } catch (_) {
        return null;
      }
    }

    String buildSubtitle(LedgerEntry entry) {
      final client = resolveClient(entry.clientId);
      final parts = <String>[formatDate(entry.date)];
      if (client != null) {
        parts.add(client.name);
      }
      return parts.join('  ·  ');
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Text(
            'Zdravo, paušalac!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Praćenje prihoda, troškova i limita paušalnog oporezivanja.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ukupno',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _OverviewRow(
                    label: 'Izdati računi',
                    value: formatCurrency(totalInvoiced),
                    icon: Icons.trending_up,
                    iconColor: Colors.green[600]!,
                  ),
                  const SizedBox(height: 12),
                  _OverviewRow(
                    label: 'Troškovi',
                    value: formatCurrency(totalExpenses),
                    icon: Icons.shopping_bag,
                    iconColor: _pastelBlueDark,
                  ),
                  const SizedBox(height: 12),
                  _OverviewRow(
                    label: 'Obaveze paušala',
                    value: formatCurrency(totalObligations),
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue[600]!,
                  ),
                  const Divider(height: 32),
                  _OverviewRow(
                    label: 'Procenjeni neto',
                    value: formatCurrency(netIncome),
                    icon: Icons.payments,
                    iconColor: Colors.purple[600]!,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Udeo prihoda po klijentima u $currentYear. godini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (clientShares.isEmpty)
                    const Text('Još uvek nema povezanih klijenata.')
                  else
                    ...clientShares.map((share) {
                      final percent = (share.share * 100).clamp(0, 100);
                      final exceedsThreshold = share.share > 0.60;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    share.client.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: exceedsThreshold
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: share.share.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                        exceedsThreshold
                                            ? Colors.redAccent
                                            : Colors.green[400]!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${percent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: exceedsThreshold
                                        ? Colors.redAccent
                                        : Colors.green[700],
                                  ),
                                ),
                                Text(
                                  formatCurrency(share.amount),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  if (clientShares.any((share) => share.share > 0.60))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pazite da pojedinačan klijent ne premaši 60% ukupnih prihoda.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.redAccent[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Limit u poslednjih 12 meseci',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: rollingProgress,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    backgroundColor: Colors.blueGrey[100],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preostalo do limita'),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(rollingRemaining as double),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Ograničenje 12m'),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(profile.rollingLimit),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Obuhvaćen period: ${formatDate(rollingWindowStart)} - ${formatDate(now)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Godišnji limit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: limitProgress,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    backgroundColor: _pastelBlueLight,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preostalo do limita'),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(remainingLimit as double),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Ukupan limit'),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(profile.annualLimit),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesečne obaveze',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContributionRow(
                    label: 'PIO doprinos',
                    value: formatCurrency(profile.monthlyPension),
                  ),
                  const SizedBox(height: 12),
                  _ContributionRow(
                    label: 'Zdravstveno osiguranje',
                    value: formatCurrency(profile.monthlyHealth),
                  ),
                  const SizedBox(height: 12),
                  _ContributionRow(
                    label: 'Akontacija poreza',
                    value: formatCurrency(profile.monthlyTaxPrepayment),
                  ),
                  const SizedBox(height: 12),
                  _ContributionRow(
                    label: 'Ukupno mesečno',
                    value: formatCurrency(profile.monthlyFixedContributions),
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poslednje aktivnosti',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (latestEntries.isEmpty)
                    const Text('Još uvek nema zabeleženih stavki.')
                  else
                    ...latestEntries
                        .take(5)
                        .map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: entry.kind == LedgerKind.invoice
                                  ? Colors.green[100]
                                  : _pastelBlueLight,
                              child: Icon(
                                entry.kind == LedgerKind.invoice
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: entry.kind == LedgerKind.invoice
                                    ? Colors.green[700]
                                    : _pastelBlueDark,
                              ),
                            ),
                            title: Text(entry.title),
                            subtitle: Text(buildSubtitle(entry)),
                            trailing: Text(
                              formatCurrency(entry.amount),
                              style: TextStyle(
                                color: entry.kind == LedgerKind.invoice
                                    ? Colors.green[700]
                                    : _pastelBlueDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerTab extends StatefulWidget {
  const LedgerTab({
    super.key,
    required this.entries,
    required this.clients,
    required this.onRemove,
    required this.onEdit,
    required this.onShareInvoice,
    required this.onPrintInvoice,
    required this.findClient,
  });

  final List<LedgerEntry> entries;
  final List<Client> clients;
  final void Function(String id) onRemove;
  final void Function(LedgerEntry entry) onEdit;
  final Future<void> Function(LedgerEntry entry) onShareInvoice;
  final Future<void> Function(LedgerEntry entry) onPrintInvoice;
  final Client? Function(String? id) findClient;

  @override
  State<LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab> {
  int? _selectedYear;
  int? _selectedMonth;
  String? _selectedClientId;

  bool get _hasActiveFilters =>
      _selectedYear != null ||
      _selectedMonth != null ||
      _selectedClientId != null;

  @override
  Widget build(BuildContext context) {
    final invoices = widget.entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final filteredInvoices = invoices.where(_matchesFilters).toList();
    final expenses = widget.entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          if (invoices.isNotEmpty) _buildFilterCard(invoices),
          if (invoices.isNotEmpty) const SizedBox(height: 16),
          _LedgerSection(
            title: 'Izdati računi',
            icon: Icons.trending_up,
            iconColor: Colors.green[600]!,
            entries: filteredInvoices,
            onRemove: widget.onRemove,
            onEdit: widget.onEdit,
            onShareInvoice: widget.onShareInvoice,
            onPrintInvoice: widget.onPrintInvoice,
            findClient: widget.findClient,
          ),
          const SizedBox(height: 24),
          _LedgerSection(
            title: 'Troškovi',
            icon: Icons.trending_down,
            iconColor: _pastelBlueDark,
            entries: expenses,
            onRemove: widget.onRemove,
            onEdit: widget.onEdit,
            onShareInvoice: widget.onShareInvoice,
            onPrintInvoice: widget.onPrintInvoice,
            findClient: widget.findClient,
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(LedgerEntry entry) {
    final matchesYear =
        _selectedYear == null || entry.date.year == _selectedYear;
    final matchesMonth =
        _selectedMonth == null || entry.date.month == _selectedMonth;
    final matchesClient =
        _selectedClientId == null || entry.clientId == _selectedClientId;
    return matchesYear && matchesMonth && matchesClient;
  }

  Widget _buildFilterCard(List<LedgerEntry> invoices) {
    final years = invoices.map((e) => e.date.year).toSet().toList()..sort();
    final months = _availableMonths(invoices, _selectedYear);
    final clientItems = widget.clients
        .map(
          (client) => DropdownMenuItem<String?>(
            value: client.id,
            child: Text(client.name),
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filteri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedYear = null;
                        _selectedMonth = null;
                        _selectedClientId = null;
                      });
                    },
                    child: const Text('Obriši filtere'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Godina',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Sve godine'),
                      ),
                      ...years.map(
                        (year) => DropdownMenuItem<int?>(
                          value: year,
                          child: Text(year.toString()),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        final available = _availableMonths(invoices, value);
                        if (_selectedMonth != null &&
                            !available.contains(_selectedMonth)) {
                          _selectedMonth = null;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Mesec',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Svi meseci'),
                      ),
                      ...months.map(
                        (month) => DropdownMenuItem<int?>(
                          value: month,
                          child: Text(_monthName(month)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Klijent',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Svi klijenti'),
                      ),
                      ...clientItems,
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<int> _availableMonths(List<LedgerEntry> invoices, int? year) {
    final filtered =
        invoices
            .where((invoice) {
              if (year == null) return true;
              return invoice.date.year == year;
            })
            .map((invoice) => invoice.date.month)
            .toSet()
            .toList()
          ..sort();
    return filtered;
  }
}

class _LedgerSection extends StatelessWidget {
  const _LedgerSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.entries,
    required this.onRemove,
    required this.onEdit,
    required this.onShareInvoice,
    required this.onPrintInvoice,
    required this.findClient,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<LedgerEntry> entries;
  final void Function(String id) onRemove;
  final void Function(LedgerEntry entry) onEdit;
  final Future<void> Function(LedgerEntry entry) onShareInvoice;
  final Future<void> Function(LedgerEntry entry) onPrintInvoice;
  final Client? Function(String? id) findClient;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupEntriesByMonth(entries);

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Još uvek nema podataka. Dodajte novu stavku.'),
                )
              else
                ...grouped.entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ),
                      ...entry.value.map((item) {
                        final client = findClient(item.clientId);
                        final detailParts = <String>[];
                        if (item.isInvoice &&
                            item.invoiceNumber?.isNotEmpty == true) {
                          detailParts.add('Faktura ${item.invoiceNumber}');
                        }
                        detailParts.add(formatDate(item.date));
                        if (client != null) {
                          detailParts.add(client.name);
                        }
                        if (item.note?.isNotEmpty == true) {
                          detailParts.add(item.note!);
                        }

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => onRemove(item.id),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => onEdit(item),
                            title: Text(item.title),
                            subtitle: Text(detailParts.join('  ·  ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatCurrency(item.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Radnje',
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      onEdit(item);
                                    } else if (value == 'delete') {
                                      onRemove(item.id);
                                    } else if (value == 'print') {
                                      await onPrintInvoice(item);
                                    } else if (value == 'share') {
                                      await onShareInvoice(item);
                                    }
                                  },
                                  itemBuilder: (menuContext) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Uredi'),
                                    ),
                                    if (item.isInvoice)
                                      const PopupMenuItem(
                                        value: 'print',
                                        child: Text('Štampa'),
                                      ),
                                    if (item.isInvoice)
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Text('PDF / Pošalji'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Obriši'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientsTab extends StatelessWidget {
  const ClientsTab({
    super.key,
    required this.clients,
    required this.entries,
    required this.onAddClient,
    required this.onEditClient,
    required this.onDeleteClient,
  });

  final List<Client> clients;
  final List<LedgerEntry> entries;
  final VoidCallback onAddClient;
  final void Function(Client client) onEditClient;
  final void Function(String id) onDeleteClient;

  @override
  Widget build(BuildContext context) {
    final invoices = entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final totalRevenue = invoices.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final clientStats = clients.map((client) {
      final revenueForClient = invoices
          .where((invoice) => invoice.clientId == client.id)
          .fold<double>(0, (sum, entry) => sum + entry.amount);
      final share = totalRevenue == 0 ? 0.0 : (revenueForClient / totalRevenue);
      return _ClientShare(
        client: client,
        amount: revenueForClient,
        share: share,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Klijenti',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: onAddClient,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Novi klijent'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Vodite računa da nijedan klijent ne premaši 60% ukupnih prihoda.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          if (clients.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text('Još uvek nema klijenata.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onAddClient,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Dodaj prvog klijenta'),
                  ),
                ],
              ),
            )
          else
            ...clientStats.map((stat) {
              final percent = (stat.share * 100).clamp(0, 100);
              final exceedsThreshold = stat.share > 0.60;
              final invoiceCount = invoices
                  .where((invoice) => invoice.clientId == stat.client.id)
                  .length;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: exceedsThreshold
                        ? Colors.redAccent.withOpacity(0.15)
                        : Colors.greenAccent.withOpacity(0.2),
                    child: Icon(
                      Icons.business,
                      color: exceedsThreshold
                          ? Colors.redAccent
                          : Colors.green[700],
                    ),
                  ),
                  title: Text(
                    stat.client.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIB: ${stat.client.pib.isEmpty ? 'N/A' : stat.client.pib}',
                      ),
                      Text(
                        stat.client.address,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stat.share.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            exceedsThreshold
                                ? Colors.redAccent
                                : Colors.green[400]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Udeo: ${percent.toStringAsFixed(1)}% · Računi: $invoiceCount · ${formatCurrency(stat.amount)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: exceedsThreshold
                              ? Colors.redAccent
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditClient(stat.client);
                      } else if (value == 'delete') {
                        onDeleteClient(stat.client.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Uredi')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Obriši'),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    super.key,
    required this.taxProfile,
    required this.companyProfile,
    required this.onProfilesChanged,
    required this.isConnected,
    required this.isSyncing,
    required this.spreadsheetId,
    required this.expensesSheet,
    required this.clientsSheet,
    required this.profileSheet,
    required this.userEmail,
    required this.onConnectSheets,
    required this.onDisconnectSheets,
  });

  final TaxProfile taxProfile;
  final CompanyProfile companyProfile;
  final void Function(TaxProfile taxProfile, CompanyProfile companyProfile)
  onProfilesChanged;
  final bool isConnected;
  final bool isSyncing;
  final String? spreadsheetId;
  final String expensesSheet;
  final String clientsSheet;
  final String profileSheet;
  final String? userEmail;
  final Future<void> Function() onConnectSheets;
  final Future<void> Function() onDisconnectSheets;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Text(
            'Paušal profil',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ažurirajte podatke o firmi i paušalu. Podaci o firmi se pojavljuju na generisanim fakturama.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          _GoogleSheetsCard(
            isConnected: isConnected,
            isSyncing: isSyncing,
            spreadsheetId: spreadsheetId,
            expensesSheet: expensesSheet,
            clientsSheet: clientsSheet,
            profileSheet: profileSheet,
            userEmail: userEmail,
            onConnectSheets: () {
              return onConnectSheets();
            },
            onDisconnectSheets: () {
              return onDisconnectSheets();
            },
          ),
          const SizedBox(height: 24),
          IgnorePointer(
            ignoring: !isConnected,
            child: Opacity(
              opacity: isConnected ? 1 : 0.5,
              child: _ProfileForm(
                taxProfile: taxProfile,
                companyProfile: companyProfile,
                onProfilesChanged: onProfilesChanged,
              ),
            ),
          ),
          if (!isConnected)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Povežite se sa Google Sheets nalogom da biste čuvali podatke o firmi i porezima.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoogleSheetsCard extends StatelessWidget {
  const _GoogleSheetsCard({
    required this.isConnected,
    required this.isSyncing,
    required this.spreadsheetId,
    required this.expensesSheet,
    required this.clientsSheet,
    required this.profileSheet,
    required this.userEmail,
    required this.onConnectSheets,
    required this.onDisconnectSheets,
  });

  final bool isConnected;
  final bool isSyncing;
  final String? spreadsheetId;
  final String expensesSheet;
  final String clientsSheet;
  final String profileSheet;
  final String? userEmail;
  final Future<void> Function() onConnectSheets;
  final Future<void> Function() onDisconnectSheets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Google Sheets sinhronizacija',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (isConnected)
              Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Povezano kao ${userEmail ?? 'Google nalog'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Podaci se čuvaju direktno u Google Sheet-u. Povežite se kako biste mogli da kreirate stavke.',
                style: theme.textTheme.bodyMedium,
              ),
            if (spreadsheetId != null && spreadsheetId!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Spreadsheet ID: $spreadsheetId',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Sheetovi: $expensesSheet (troškovi), $clientsSheet (klijenti), $profileSheet (profil)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (isSyncing)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Row(
              children: [
                if (isConnected)
                  OutlinedButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () async {
                            await onDisconnectSheets();
                          },
                    icon: const Icon(Icons.link_off),
                    label: const Text('Prekini vezu'),
                  )
                else
                  FilledButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () async {
                            await onConnectSheets();
                          },
                    icon: const Icon(Icons.cloud_sync),
                    label: const Text('Poveži Google Sheets'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectSheetPlaceholder extends StatelessWidget {
  const _ConnectSheetPlaceholder({
    required this.isConnecting,
    required this.onConnect,
  });

  final bool isConnecting;
  final Future<void> Function() onConnect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_sync,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Povežite Google Sheets nalog',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Za unos faktura, troškova i klijenata potrebno je da povežete svoj Google Sheets dokument.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: isConnecting
                    ? null
                    : () async {
                        await onConnect();
                      },
                icon: const Icon(Icons.login),
                label: Text(
                  isConnecting ? 'Povezivanje...' : 'Poveži Google Sheets',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({
    required this.taxProfile,
    required this.companyProfile,
    required this.onProfilesChanged,
  });

  final TaxProfile taxProfile;
  final CompanyProfile companyProfile;
  final void Function(TaxProfile taxProfile, CompanyProfile companyProfile)
  onProfilesChanged;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cityController;
  late TextEditingController _pensionController;
  late TextEditingController _healthController;
  late TextEditingController _taxController;
  late TextEditingController _limitController;
  late TextEditingController _rollingLimitController;
  late TextEditingController _rateController;
  late TextEditingController _companyNameController;
  late TextEditingController _companyShortNameController;
  late TextEditingController _companyPibController;
  late TextEditingController _companyAddressController;
  late TextEditingController _companyAccountController;
  late TextEditingController _companyResponsibleController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.taxProfile.city);
    _pensionController = TextEditingController(
      text: widget.taxProfile.monthlyPension.toStringAsFixed(0),
    );
    _healthController = TextEditingController(
      text: widget.taxProfile.monthlyHealth.toStringAsFixed(0),
    );
    _taxController = TextEditingController(
      text: widget.taxProfile.monthlyTaxPrepayment.toStringAsFixed(0),
    );
    _limitController = TextEditingController(
      text: widget.taxProfile.annualLimit.toStringAsFixed(0),
    );
    _rollingLimitController = TextEditingController(
      text: widget.taxProfile.rollingLimit.toStringAsFixed(0),
    );
    _rateController = TextEditingController(
      text: (widget.taxProfile.additionalTaxRate * 100).toStringAsFixed(1),
    );
    _companyNameController = TextEditingController(
      text: widget.companyProfile.name,
    );
    _companyShortNameController = TextEditingController(
      text: widget.companyProfile.shortName,
    );
    _companyPibController = TextEditingController(
      text: widget.companyProfile.pib,
    );
    _companyAddressController = TextEditingController(
      text: widget.companyProfile.address,
    );
    _companyAccountController = TextEditingController(
      text: widget.companyProfile.accountNumber,
    );
    _companyResponsibleController = TextEditingController(
      text: widget.companyProfile.responsiblePerson,
    );
  }

  @override
  void didUpdateWidget(covariant _ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taxProfile != oldWidget.taxProfile) {
      _cityController.text = widget.taxProfile.city;
      _pensionController.text = widget.taxProfile.monthlyPension
          .toStringAsFixed(0);
      _healthController.text = widget.taxProfile.monthlyHealth.toStringAsFixed(
        0,
      );
      _taxController.text = widget.taxProfile.monthlyTaxPrepayment
          .toStringAsFixed(0);
      _limitController.text = widget.taxProfile.annualLimit.toStringAsFixed(0);
      _rollingLimitController.text = widget.taxProfile.rollingLimit
          .toStringAsFixed(0);
      _rateController.text = (widget.taxProfile.additionalTaxRate * 100)
          .toStringAsFixed(1);
    }
    if (widget.companyProfile != oldWidget.companyProfile) {
      _companyNameController.text = widget.companyProfile.name;
      _companyShortNameController.text = widget.companyProfile.shortName;
      _companyPibController.text = widget.companyProfile.pib;
      _companyAddressController.text = widget.companyProfile.address;
      _companyAccountController.text = widget.companyProfile.accountNumber;
      _companyResponsibleController.text =
          widget.companyProfile.responsiblePerson;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _pensionController.dispose();
    _healthController.dispose();
    _taxController.dispose();
    _limitController.dispose();
    _rollingLimitController.dispose();
    _rateController.dispose();
    _companyNameController.dispose();
    _companyShortNameController.dispose();
    _companyPibController.dispose();
    _companyAddressController.dispose();
    _companyAccountController.dispose();
    _companyResponsibleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    double parseAmount(String input) {
      return double.parse(input.trim().replaceAll(',', '.'));
    }

    final updatedProfile = widget.taxProfile.copyWith(
      city: _cityController.text.trim(),
      monthlyPension: parseAmount(_pensionController.text),
      monthlyHealth: parseAmount(_healthController.text),
      monthlyTaxPrepayment: parseAmount(_taxController.text),
      annualLimit: parseAmount(_limitController.text),
      rollingLimit: parseAmount(_rollingLimitController.text),
      additionalTaxRate: parseAmount(_rateController.text) / 100,
    );

    final updatedCompany = widget.companyProfile.copyWith(
      name: _companyNameController.text.trim(),
      shortName: _companyShortNameController.text.trim(),
      responsiblePerson: _companyResponsibleController.text.trim(),
      pib: _companyPibController.text.trim(),
      address: _companyAddressController.text.trim(),
      accountNumber: _companyAccountController.text.trim(),
    );

    widget.onProfilesChanged(updatedProfile, updatedCompany);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Podaci sačuvani')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Podaci o firmi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Naziv firme',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Unesite naziv';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyShortNameController,
            decoration: const InputDecoration(
              labelText: 'Skraćeni naziv (opciono)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyResponsibleController,
            decoration: const InputDecoration(
              labelText: 'Odgovorno lice',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyPibController,
            decoration: const InputDecoration(
              labelText: 'PIB',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyAddressController,
            decoration: const InputDecoration(
              labelText: 'Adresa',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyAccountController,
            decoration: const InputDecoration(
              labelText: 'Broj računa',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Poreski podaci paušala',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Grad',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pensionController,
            decoration: const InputDecoration(
              labelText: 'PIO doprinos (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _healthController,
            decoration: const InputDecoration(
              labelText: 'Zdravstveno osiguranje (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _taxController,
            decoration: const InputDecoration(
              labelText: 'Akontacija poreza (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _limitController,
            decoration: const InputDecoration(
              labelText: 'Godišnji limit prihoda',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rollingLimitController,
            decoration: const InputDecoration(
              labelText: 'Limit u poslednjih 12 meseci',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rateController,
            decoration: const InputDecoration(
              labelText: 'Dodatni porez (u %)',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed < 0) {
                return 'Unesite broj veći ili jednak nuli';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Sačuvaj promene'),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({
    super.key,
    required this.onSubmit,
    required this.clients,
    required this.onCreateClient,
    required this.existingEntries,
    this.initialEntry,
    this.onDelete,
  });

  final LedgerEntry? initialEntry;
  final void Function(LedgerEntry entry) onSubmit;
  final VoidCallback? onDelete;
  final List<Client> clients;
  final void Function(Client client) onCreateClient;
  final List<LedgerEntry> existingEntries;

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _clientSearchController;
  late LedgerKind _selectedKind;
  late DateTime _selectedDate;
  String? _selectedClientId;
  late List<_InvoiceItemFormData> _invoiceItems;
  double _invoiceTotal = 0;
  late TextEditingController _invoiceNumberController;
  bool _invoiceNumberAutoFilled = false;

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEntry;
    _selectedKind = initial?.kind ?? LedgerKind.invoice;
    _selectedDate = initial?.date ?? DateTime.now();
    _titleController = TextEditingController(text: initial?.title ?? '');
    _amountController = TextEditingController(
      text: initial != null ? initial.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _clientSearchController = TextEditingController();
    _selectedClientId = initial?.clientId;
    _invoiceItems = <_InvoiceItemFormData>[];
    if (_selectedKind == LedgerKind.invoice) {
      if (initial?.invoiceNumber?.trim().isNotEmpty == true) {
        _invoiceNumberController = TextEditingController(
          text: initial!.invoiceNumber!.trim(),
        );
        _invoiceNumberAutoFilled = false;
      } else {
        _invoiceNumberController = TextEditingController(
          text: _suggestInvoiceNumber(_selectedDate),
        );
        _invoiceNumberAutoFilled = true;
      }
    } else {
      _invoiceNumberController = TextEditingController(text: '');
      _invoiceNumberAutoFilled = true;
    }

    final hasClient =
        _selectedClientId != null &&
        widget.clients.any((client) => client.id == _selectedClientId);
    if (!hasClient) {
      _selectedClientId = null;
    }
    if (_selectedKind == LedgerKind.invoice &&
        _selectedClientId == null &&
        widget.clients.isNotEmpty) {
      _selectedClientId = widget.clients.first.id;
    }
    if (_selectedKind == LedgerKind.expense) {
      _selectedClientId = null;
    }
    _refreshClientSearchField();
    if (_selectedKind == LedgerKind.invoice) {
      _initializeInvoiceItems(initial);
    }
  }

  @override
  void didUpdateWidget(covariant AddEntrySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clients != widget.clients) {
      setState(_refreshClientSearchField);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _clientSearchController.dispose();
    _invoiceNumberController.dispose();
    for (final item in _invoiceItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (_selectedKind == LedgerKind.invoice && !_isEditing) {
        if (_invoiceNumberAutoFilled ||
            _invoiceNumberController.text.trim().isEmpty) {
          _invoiceNumberController.text = _suggestInvoiceNumber(picked);
          _invoiceNumberAutoFilled = true;
        }
      }
    }
  }

  Future<void> _createClient() async {
    final newClient = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return AddClientSheet(onSubmit: widget.onCreateClient);
      },
    );

    if (newClient != null) {
      setState(() {
        _selectedClientId = newClient.id;
        _clientSearchController.text = newClient.name;
      });
    }
  }

  void _initializeInvoiceItems(LedgerEntry? initial) {
    final existing = initial?.items ?? const [];
    if (existing.isNotEmpty) {
      _invoiceItems = existing
          .map(
            (item) => _InvoiceItemFormData(
              description: item.description,
              unit: item.unit,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList();
    } else {
      final fallbackAmount = initial?.amount ?? 0;
      final fallbackDescription = initial?.title ?? '';
      _invoiceItems = [
        _InvoiceItemFormData(
          description: fallbackDescription,
          unit: 'radni sat',
          quantity: 1,
          unitPrice: fallbackAmount > 0 ? fallbackAmount : 0,
        ),
      ];
    }
    _recalculateInvoiceTotal(updateText: true, notify: false);
  }

  void _ensureInvoiceItemsPresent() {
    if (_invoiceItems.isEmpty) {
      _invoiceItems = [
        _InvoiceItemFormData(
          description: _titleController.text.trim(),
          unit: 'radni sat',
          quantity: 1,
          unitPrice: 0,
        ),
      ];
      _recalculateInvoiceTotal(updateText: true, notify: false);
    }
  }

  void _addInvoiceItem() {
    setState(() {
      _invoiceItems.add(_InvoiceItemFormData());
      _recalculateInvoiceTotal(updateText: true, notify: false);
    });
  }

  void _removeInvoiceItem(int index) {
    if (_invoiceItems.length <= 1) {
      return;
    }
    setState(() {
      final removed = _invoiceItems.removeAt(index);
      removed.dispose();
      _recalculateInvoiceTotal(updateText: true, notify: false);
    });
  }

  void _recalculateInvoiceTotal({bool updateText = false, bool notify = true}) {
    final total = _invoiceItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    if (updateText) {
      _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';
    }
    if (notify) {
      setState(() {
        _invoiceTotal = total;
      });
    } else {
      _invoiceTotal = total;
    }
  }

  Client? _findClientById(String? id) {
    if (id == null) {
      return null;
    }
    for (final client in widget.clients) {
      if (client.id == id) {
        return client;
      }
    }
    return null;
  }

  void _refreshClientSearchField() {
    final client = _findClientById(_selectedClientId);
    _clientSearchController.text = client?.name ?? '';
  }

  Future<void> _openClientSearch() async {
    final result = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = widget.clients.where((client) {
              if (query.isEmpty) return true;
              final lower = query.toLowerCase();
              return client.name.toLowerCase().contains(lower) ||
                  client.pib.toLowerCase().contains(lower);
            }).toList()..sort((a, b) => a.name.compareTo(b.name));
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Pretraga klijenata',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setModalState(() {
                        query = value.trim();
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('Nema klijenata za zadati kriterijum.'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final client = filtered[index];
                            return ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(client.name),
                              subtitle: client.pib.isEmpty
                                  ? null
                                  : Text('PIB: ${client.pib}'),
                              onTap: () =>
                                  Navigator.of(sheetContext).pop(client),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedClientId = result.id;
        _clientSearchController.text = result.name;
      });
    }
  }

  String _suggestInvoiceNumber(DateTime date) {
    final excludeId = widget.initialEntry?.id;
    final count = widget.existingEntries.where((entry) {
      if (entry.kind != LedgerKind.invoice) return false;
      if (excludeId != null && entry.id == excludeId) return false;
      return entry.date.year == date.year;
    }).length;
    final next = count + 1;
    final numberPart = next.toString().padLeft(2, '0');
    return '$numberPart-${date.year}';
  }

  Widget _buildInvoiceItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stavke fakture',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addInvoiceItem,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj stavku'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_invoiceItems.length, (index) {
          final data = _invoiceItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InvoiceItemRow(
              index: index,
              data: data,
              onChanged: () => _recalculateInvoiceTotal(updateText: true),
              onRemove: _invoiceItems.length > 1
                  ? () => _removeInvoiceItem(index)
                  : null,
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Ukupno: ${formatCurrency(_invoiceTotal)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String? clientId;
    if (_selectedKind == LedgerKind.invoice) {
      clientId = _selectedClientId;
      if (clientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Odaberite klijenta za fakturu')),
        );
        return;
      }
    }

    double amount;
    List<InvoiceItem> invoiceItems = const [];
    if (_selectedKind == LedgerKind.invoice) {
      invoiceItems = _invoiceItems
          .map((item) => item.toInvoiceItem())
          .where(
            (item) =>
                item.description.trim().isNotEmpty &&
                item.quantity > 0 &&
                item.unitPrice > 0,
          )
          .toList();
      amount = invoiceItems.fold<double>(0, (sum, item) => sum + item.total);
      if (invoiceItems.isEmpty || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dodajte bar jednu stavku sa cenom i količinom.'),
          ),
        );
        return;
      }
      final numberValue = _invoiceNumberController.text.trim();
      if (numberValue.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unesite broj fakture.')));
        return;
      }
      _invoiceNumberAutoFilled = false;
    } else {
      final parsed = double.tryParse(
        _amountController.text.replaceAll(',', '.'),
      );
      if (parsed == null) {
        return;
      }
      amount = parsed;
    }

    final entry = LedgerEntry(
      id:
          widget.initialEntry?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      kind: _selectedKind,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      clientId: clientId,
      invoiceNumber: _selectedKind == LedgerKind.invoice
          ? _invoiceNumberController.text.trim()
          : null,
      items: _selectedKind == LedgerKind.invoice ? invoiceItems : const [],
    );

    widget.onSubmit(entry);
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final titleText = _isEditing ? 'Izmena stavke' : 'Nova stavka';
    final primaryActionLabel = _isEditing ? 'Sačuvaj izmene' : 'Sačuvaj stavku';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(minHeight: 44, minWidth: 120),
                isSelected: [
                  _selectedKind == LedgerKind.invoice,
                  _selectedKind == LedgerKind.expense,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedKind = LedgerKind.values[index];
                    if (_selectedKind == LedgerKind.expense) {
                      _selectedClientId = null;
                      _invoiceNumberController.text = '';
                      _invoiceNumberAutoFilled = true;
                      _clientSearchController.clear();
                      if (widget.initialEntry != null &&
                          widget.initialEntry!.kind == LedgerKind.expense) {
                        _amountController.text = widget.initialEntry!.amount
                            .toStringAsFixed(2);
                      } else if (!_isEditing) {
                        _amountController.clear();
                      }
                    } else {
                      if (_selectedClientId == null &&
                          widget.clients.isNotEmpty) {
                        _selectedClientId = widget.clients.first.id;
                      }
                      _ensureInvoiceItemsPresent();
                      _refreshClientSearchField();
                      if (!_isEditing ||
                          (widget.initialEntry?.invoiceNumber?.trim().isEmpty ??
                              true)) {
                        final suggestion = _suggestInvoiceNumber(_selectedDate);
                        _invoiceNumberController.text = suggestion;
                        _invoiceNumberAutoFilled = true;
                      } else {
                        _invoiceNumberAutoFilled = false;
                      }
                      _recalculateInvoiceTotal(updateText: true, notify: false);
                    }
                  });
                  if (_selectedKind == LedgerKind.invoice) {
                    _recalculateInvoiceTotal(updateText: true);
                  }
                },
                children: const [
                  _SegmentOption(icon: Icons.trending_up, label: 'Prihod'),
                  _SegmentOption(icon: Icons.trending_down, label: 'Trošak'),
                ],
              ),
              if (_selectedKind == LedgerKind.invoice) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clientSearchController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Klijent',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onTap: _openClientSearch,
                        validator: (_) {
                          if (_selectedClientId == null ||
                              _selectedClientId!.isEmpty) {
                            return 'Odaberite klijenta';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _createClient,
                      tooltip: 'Novi klijent',
                      icon: const Icon(Icons.person_add_alt),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Broj fakture',
                    hintText: 'npr. 10-2025',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _invoiceNumberAutoFilled = false,
                  validator: (value) {
                    if (_selectedKind != LedgerKind.invoice) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Unesite broj fakture';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedKind == LedgerKind.invoice
                      ? 'Opis fakture'
                      : 'Naziv troška',
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unesite naziv';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedKind == LedgerKind.invoice) ...[
                _buildInvoiceItemsSection(context),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _amountController,
                readOnly: _selectedKind == LedgerKind.invoice,
                decoration: InputDecoration(
                  labelText: 'Ukupan iznos',
                  suffixText: 'RSD',
                  border: const OutlineInputBorder(),
                  helperText: _selectedKind == LedgerKind.invoice
                      ? 'Automatski se računa na osnovu stavki'
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (_selectedKind == LedgerKind.invoice) {
                    return null;
                  }
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) {
                    return 'Unesite iznos veći od nule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Datum',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(formatDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _pickDate,
                    tooltip: 'Izaberi datum',
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Napomena (opciono)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.onDelete != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.onDelete?.call();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Obriši'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(primaryActionLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceItemFormData {
  _InvoiceItemFormData({
    String description = '',
    String unit = 'radni sat',
    double quantity = 1,
    double unitPrice = 0,
  }) : descriptionController = TextEditingController(text: description),
       unitController = ValueNotifier<String>(unit),
       quantityController = TextEditingController(
         text: quantity > 0 ? _formatNumber(quantity) : '',
       ),
       unitPriceController = TextEditingController(
         text: unitPrice > 0 ? unitPrice.toStringAsFixed(2) : '',
       );

  final TextEditingController descriptionController;
  final ValueNotifier<String> unitController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  double get quantity =>
      double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
  double get unitPrice =>
      double.tryParse(unitPriceController.text.replaceAll(',', '.')) ?? 0;
  double get total => quantity * unitPrice;

  String get unit =>
      unitController.value.trim().isEmpty ? 'jed' : unitController.value.trim();

  InvoiceItem toInvoiceItem() {
    return InvoiceItem(
      description: descriptionController.text.trim(),
      unit: unit,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  void dispose() {
    descriptionController.dispose();
    unitController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }

  static String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}

class _InvoiceItemRow extends StatelessWidget {
  const _InvoiceItemRow({
    required this.index,
    required this.data,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final _InvoiceItemFormData data;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalLabel = formatCurrency(data.total);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stavka ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Ukloni stavku',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: data.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis stavke',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite opis stavke';
                }
                return null;
              },
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: data.unitController,
                    builder: (context, value, _) {
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: const InputDecoration(
                          labelText: 'Jedinica mere',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'radni sat',
                            child: Text('Radni sat'),
                          ),
                          DropdownMenuItem(value: 'kom', child: Text('Komad')),
                        ],
                        onChanged: (selected) {
                          if (selected == null) return;
                          data.unitController.value = selected;
                          onChanged();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: data.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Količina',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite količinu';
                      }
                      return null;
                    },
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: data.unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Cena po jedinici',
                      suffixText: 'RSD',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite cenu';
                      }
                      return null;
                    },
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Iznos stavke: $totalLabel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddClientSheet extends StatefulWidget {
  const AddClientSheet({
    super.key,
    required this.onSubmit,
    this.initialClient,
    this.onDelete,
  });

  final Client? initialClient;
  final void Function(Client client) onSubmit;
  final VoidCallback? onDelete;

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pibController;
  late final TextEditingController _addressController;

  bool get _isEditing => widget.initialClient != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialClient?.name ?? '',
    );
    _pibController = TextEditingController(
      text: widget.initialClient?.pib ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialClient?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pibController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final client = Client(
      id:
          widget.initialClient?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      pib: _pibController.text.trim(),
      address: _addressController.text.trim(),
    );

    widget.onSubmit(client);
    Navigator.of(context).pop(client);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final titleText = _isEditing ? 'Izmena klijenta' : 'Novi klijent';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Naziv klijenta',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unesite naziv klijenta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pibController,
                decoration: const InputDecoration(
                  labelText: 'PIB',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresa',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.onDelete != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.onDelete?.call();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Obriši'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Sačuvaj'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpreadsheetConfig {
  const _SpreadsheetConfig({
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

enum LedgerKind { invoice, expense }

class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
    this.clientId,
    this.invoiceNumber,
    List<InvoiceItem>? items,
  }) : items = List<InvoiceItem>.unmodifiable(items ?? const []);

  final String id;
  final LedgerKind kind;
  final String title;
  final double amount;
  final DateTime date;
  final String? note;
  final String? clientId;
  final String? invoiceNumber;
  final List<InvoiceItem> items;

  bool get isInvoice => kind == LedgerKind.invoice;
  double get totalFromItems =>
      items.fold<double>(0, (sum, item) => sum + item.total);

  LedgerEntry copyWith({
    LedgerKind? kind,
    String? title,
    double? amount,
    DateTime? date,
    String? note,
    bool clearNote = false,
    String? clientId,
    bool clearClient = false,
    String? invoiceNumber,
    List<InvoiceItem>? items,
  }) {
    return LedgerEntry(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
      clientId: clearClient ? null : (clientId ?? this.clientId),
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    final kindValue = json['kind'] as String? ?? LedgerKind.invoice.name;
    final kind = LedgerKind.values.firstWhere(
      (value) => value.name == kindValue,
      orElse: () => LedgerKind.invoice,
    );
    final parsedItems = _parseInvoiceItems(json['items']);
    final baseAmount = (json['amount'] as num?)?.toDouble() ?? 0;
    final computedAmount = parsedItems.isNotEmpty
        ? parsedItems.fold<double>(0, (sum, item) => sum + item.total)
        : baseAmount;
    final rawInvoiceNumber = json['invoiceNumber'] as String?;
    final normalizedInvoiceNumber =
        rawInvoiceNumber != null && rawInvoiceNumber.trim().isNotEmpty
        ? rawInvoiceNumber.trim()
        : null;
    return LedgerEntry(
      id: json['id'] as String? ?? '',
      kind: kind,
      title: json['title'] as String? ?? '',
      amount: computedAmount,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
      clientId: json['clientId'] as String?,
      invoiceNumber: normalizedInvoiceNumber,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'clientId': clientId,
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  static List<InvoiceItem> _parseInvoiceItems(dynamic raw) {
    if (raw == null) {
      return const [];
    }
    try {
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .where((element) => element is Map)
              .map(
                (element) => InvoiceItem.fromJson(
                  Map<String, dynamic>.from(element as Map),
                ),
              )
              .toList();
        }
      } else if (raw is List) {
        return raw
            .where((element) => element is Map)
            .map(
              (element) => InvoiceItem.fromJson(
                Map<String, dynamic>.from(element as Map),
              ),
            )
            .toList();
      }
    } catch (_) {
      // ignore malformed data
    }
    return const [];
  }
}

class InvoiceItem {
  const InvoiceItem({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final String unit;
  final double quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  InvoiceItem copyWith({
    String? description,
    String? unit,
    double? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kom',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.pib,
    required this.address,
  });

  final String id;
  final String name;
  final String pib;
  final String address;

  Client copyWith({String? name, String? pib, String? address}) {
    return Client(
      id: id,
      name: name ?? this.name,
      pib: pib ?? this.pib,
      address: address ?? this.address,
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pib: json['pib'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'pib': pib, 'address': address};
  }
}

class CompanyProfile {
  const CompanyProfile({
    required this.name,
    required this.shortName,
    required this.responsiblePerson,
    required this.pib,
    required this.address,
    required this.accountNumber,
  });

  final String name;
  final String shortName;
  final String responsiblePerson;
  final String pib;
  final String address;
  final String accountNumber;

  CompanyProfile copyWith({
    String? name,
    String? shortName,
    String? responsiblePerson,
    String? pib,
    String? address,
    String? accountNumber,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      pib: pib ?? this.pib,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      responsiblePerson: json['responsiblePerson'] as String? ?? '',
      pib: json['pib'] as String? ?? '',
      address: json['address'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'responsiblePerson': responsiblePerson,
      'pib': pib,
      'address': address,
      'accountNumber': accountNumber,
    };
  }
}

class TaxProfile {
  const TaxProfile({
    required this.city,
    required this.monthlyPension,
    required this.monthlyHealth,
    required this.monthlyTaxPrepayment,
    required this.annualLimit,
    required this.rollingLimit,
    required this.additionalTaxRate,
  });

  final String city;
  final double monthlyPension;
  final double monthlyHealth;
  final double monthlyTaxPrepayment;
  final double annualLimit;
  final double rollingLimit;
  final double additionalTaxRate;

  double get monthlyFixedContributions =>
      monthlyPension + monthlyHealth + monthlyTaxPrepayment;

  TaxProfile copyWith({
    String? city,
    double? monthlyPension,
    double? monthlyHealth,
    double? monthlyTaxPrepayment,
    double? annualLimit,
    double? rollingLimit,
    double? additionalTaxRate,
  }) {
    return TaxProfile(
      city: city ?? this.city,
      monthlyPension: monthlyPension ?? this.monthlyPension,
      monthlyHealth: monthlyHealth ?? this.monthlyHealth,
      monthlyTaxPrepayment: monthlyTaxPrepayment ?? this.monthlyTaxPrepayment,
      annualLimit: annualLimit ?? this.annualLimit,
      rollingLimit: rollingLimit ?? this.rollingLimit,
      additionalTaxRate: additionalTaxRate ?? this.additionalTaxRate,
    );
  }

  factory TaxProfile.fromJson(Map<String, dynamic> json) {
    return TaxProfile(
      city: json['city'] as String? ?? '',
      monthlyPension: (json['monthlyPension'] as num?)?.toDouble() ?? 0,
      monthlyHealth: (json['monthlyHealth'] as num?)?.toDouble() ?? 0,
      monthlyTaxPrepayment:
          (json['monthlyTaxPrepayment'] as num?)?.toDouble() ?? 0,
      annualLimit: (json['annualLimit'] as num?)?.toDouble() ?? 0,
      rollingLimit: (json['rollingLimit'] as num?)?.toDouble() ?? 0,
      additionalTaxRate: (json['additionalTaxRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'monthlyPension': monthlyPension,
      'monthlyHealth': monthlyHealth,
      'monthlyTaxPrepayment': monthlyTaxPrepayment,
      'annualLimit': annualLimit,
      'rollingLimit': rollingLimit,
      'additionalTaxRate': additionalTaxRate,
    };
  }
}

int _countTrackedMonths(List<LedgerEntry> entries) {
  final months = entries
      .map((entry) => DateTime(entry.date.year, entry.date.month))
      .toSet();
  return months.length;
}

Map<String, List<LedgerEntry>> _groupEntriesByMonth(List<LedgerEntry> entries) {
  final sorted = entries.toList()..sort((a, b) => b.date.compareTo(a.date));
  final Map<String, List<LedgerEntry>> grouped = {};
  for (final entry in sorted) {
    final key = '${_monthName(entry.date.month)} ${entry.date.year}';
    grouped.putIfAbsent(key, () => []).add(entry);
  }
  return grouped;
}

String _monthName(int month) {
  const monthNames = [
    'januar',
    'februar',
    'mart',
    'april',
    'maj',
    'jun',
    'jul',
    'avgust',
    'septembar',
    'oktobar',
    'novembar',
    'decembar',
  ];
  return monthNames[month - 1];
}

String formatCurrency(double value) {
  final sign = value < 0 ? '-' : '';
  final absValue = value.abs();
  final parts = absValue.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];
  final separated = integerPart.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'RSD $sign$separated,$decimalPart';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year.';
}

pw.Font? _invoiceFontRegular;
pw.Font? _invoiceFontBold;

Future<void> _ensureInvoiceFonts() async {
  _invoiceFontRegular ??= pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  _invoiceFontBold ??= pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
  );
}

Future<Uint8List> _buildInvoicePdf(
  LedgerEntry entry,
  Client client,
  CompanyProfile company,
  TaxProfile profile,
) async {
  await _ensureInvoiceFonts();
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: _invoiceFontRegular!,
      bold: _invoiceFontBold!,
    ),
  );
  final issueDate = formatDate(entry.date);
  final dueDate = formatDate(entry.date.add(const Duration(days: 14)));
  final generatedOn = formatDate(DateTime.now());
  final amountText = formatCurrency(entry.amount);
  final noteText = entry.note?.trim().isNotEmpty == true
      ? entry.note!.trim()
      : '—';
  final inferredNumber =
      '${entry.date.month.toString().padLeft(2, '0')}-${entry.date.year}';
  final invoiceNumber = entry.invoiceNumber?.trim().isNotEmpty == true
      ? entry.invoiceNumber!.trim()
      : inferredNumber;
  // final shortTitle = company.shortName.trim().isNotEmpty
  //     ? company.shortName.trim()
  //     : '';
  // final fullTitle = company.name.trim().isNotEmpty
  //     ? company.name.trim()
  //     : '';

  final items = entry.items.isNotEmpty
      ? entry.items
      : [
          InvoiceItem(
            description: entry.title,
            unit: 'usluga',
            quantity: 1,
            unitPrice: entry.amount,
          ),
        ];
  String formatQuantity(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  String tableCurrency(double value) =>
      formatCurrency(value).replaceFirst('RSD ', '');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (company.shortName.isNotEmpty)
                      pw.Text(
                        company.shortName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    if (company.name.isNotEmpty)
                      pw.Text(company.name, style: pw.TextStyle(fontSize: 10)),

                    if (company.address.isNotEmpty)
                      pw.Text(
                        company.address,
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    pw.Text(
                      profile.city,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(width: 24),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (company.pib.isNotEmpty)
                      pw.Text(
                        'PIB: ${company.pib}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (company.accountNumber.isNotEmpty)
                      pw.Text(
                        'T.R.: ${company.accountNumber}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    // pw.Text('Datum izrade: $generatedOn',
                    //     style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Faktura br.: $invoiceNumber',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Datum računa: $issueDate',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'Datum dospeća: $dueDate',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    '${profile.city}, ${issueDate}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Kupac',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text(client.name, style: const pw.TextStyle(fontSize: 12)),
                if (client.pib.isNotEmpty)
                  pw.Text(
                    'PIB: ${client.pib}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                if (client.address.isNotEmpty)
                  pw.Text(
                    client.address,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
            columnWidths: {
              0: const pw.FixedColumnWidth(32),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1.4),
              5: const pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'R.br',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Vrsta robe / usluge',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Container(
                      width: 50,
                      child: pw.Text(
                        'Jedinica mere',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Količina',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Cena / jedinici (RSD)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Ukupno (RSD)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...items.asMap().entries.map((itemEntry) {
                final index = itemEntry.key + 1;
                final item = itemEntry.value;
                final description = item.description.trim().isEmpty
                    ? '—'
                    : item.description;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(index.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(description),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.unit),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(formatQuantity(item.quantity)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(tableCurrency(item.unitPrice)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(tableCurrency(item.total)),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'IZNOS UKUPNO  $amountText',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Divider(height: 1, thickness: 1),
          pw.SizedBox(height: 6),
          pw.Text(
            'Izdavalac računa nije obveznik PDV-a po članu 33. zakona o PDV',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            'Izdavalac računa je paušalni obveznik poreza po članu 42. Zakona o porezu na dohodak',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),

          if (noteText != '—') ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Dodatna napomena:',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(noteText, style: const pw.TextStyle(fontSize: 10)),
          ],

          pw.SizedBox(height: 12),
          pw.Text(
            'Način plaćanja: Virman',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Valuta plaćanja: 14 dana',
            style: const pw.TextStyle(fontSize: 11),
          ),

          pw.SizedBox(height: 12),
          pw.Text(
            'Uplatu izvršiti na račun: ${company.accountNumber}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Poziv na broj: $invoiceNumber',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // pw.Text('Obračun doprinosa (mesečno):',
                  //     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  // pw.Text(
                  //   'PIO: ${formatCurrency(profile.monthlyPension)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                  // pw.Text(
                  //   'Zdravstveno: ${formatCurrency(profile.monthlyHealth)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                  // pw.Text(
                  //   'Akontacija poreza: ${formatCurrency(profile.monthlyTaxPrepayment)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Odgovorno lice',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    width: 160,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey500, width: 1),
                      ),
                    ),
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      company.responsiblePerson.isNotEmpty
                          ? company.responsiblePerson
                          : (company.shortName.isNotEmpty
                                ? company.shortName
                                : company.name),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
        ],
      ),
    ),
  );

  return pdf.save();
}

String _sanitizeFileName(String input) {
  final fallback = input.isEmpty ? 'faktura' : input;
  final sanitized = fallback
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return sanitized.isEmpty ? 'faktura' : sanitized;
}

String? _validatePositiveNumber(String? value) {
  final sanitized = value?.replaceAll(',', '.');
  final parsed = double.tryParse(sanitized ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Unesite broj veći od nule';
  }
  return null;
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}

class _ClientShare {
  const _ClientShare({
    required this.client,
    required this.amount,
    required this.share,
  });

  final Client client;
  final double amount;
  final double share;
}
