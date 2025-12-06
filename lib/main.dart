import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

import 'constants/app_constants.dart';
import 'screens/landing_page.dart';
import 'screens/app/pausal_home.dart';
import 'screens/privacy_policy_page.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    SharedPreferencesPlugin.registerWith(null);
    // GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  runApp(const PausalApp());
}

class PausalApp extends StatefulWidget {
  const PausalApp({super.key});

  @override
  State<PausalApp> createState() => _PausalAppState();
}

class _PausalAppState extends State<PausalApp> {
  Locale _locale = const Locale('sr', ''); // Serbian as default

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paušal kalkulator',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('sr', ''), // Serbian
        Locale('en', ''), // English
      ],
      locale: _locale, // Use the selected locale
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: pastelBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PausalHome(onLanguageChange: _changeLanguage),
        '/about': (context) => LandingPage(onLanguageChange: _changeLanguage),
        // '/app': (context) => PausalHome(onLanguageChange: _changeLanguage),
        '/privacy_policy': (context) => PrivacyPolicyPage(onLanguageChange: _changeLanguage),
      },
    );
  }
}

