import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

import 'constants/app_constants.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/app/pausal_home.dart';
import 'screens/privacy_policy_page.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    SharedPreferencesPlugin.registerWith(null);
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  runApp(const PausalApp());
}

class PausalApp extends StatelessWidget {
  const PausalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paušal kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: pastelBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/app': (context) => const PausalHome(),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
      },
    );
  }
}

