import 'package:flutter/material.dart';

import '../widgets/landing_bullet.dart';

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
                        LandingBullet(
                          icon: Icons.dashboard_customize,
                          title: 'Pregled poslovanja',
                          description:
                              'Automatski izračunava promet, troškove, neto prihod i poreske obaveze po osnovu paušalnog oporezivanja.',
                        ),
                        LandingBullet(
                          icon: Icons.people_outline,
                          title: 'Upravljanje klijentima',
                          description:
                              'Pratite prihod po klijentu, evidentirajte ugovore i vodite računa o propisanim limitima.',
                        ),
                        LandingBullet(
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
                          'Šta je novo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        LandingBullet(
                          icon: Icons.cloud_done_outlined,
                          title: 'Google Sheets sinhronizacija',
                          description:
                              'Podaci se povezuju direktno sa vašim Google Sheets dokumentom – aplikacija čita i ažurira isti fajl bez manualnog export/import procesa.',
                        ),
                        LandingBullet(
                          icon: Icons.check_circle_outline,
                          title: 'Jednostavan onboarding',
                          description:
                              'Povežite postojeći sheet ili kreirajte novi dokument sa svim potrebnim listovima: troškovi, klijenti i profil firme.',
                        ),
                        LandingBullet(
                          icon: Icons.security_outlined,
                          title: 'Potpuna kontrola podataka',
                          description:
                              'Podaci ostaju u vašem Google nalogu. Aplikacija koristi samo one dozvole koje ste eksplicitno odobrili.',
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
                          'Važni linkovi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        LandingBullet(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Politika privatnosti',
                          description:
                              'Detaljno objašnjava koje Google naloge i Sheets dozvole koristimo i zašto.',
                        ),
                        LandingBullet(
                          icon: Icons.mail_outline,
                          title: 'Kontakt podrška',
                          description:
                              'Pišite na office@finaccons.rs za pomoć u podešavanju ili prijavu grešaka.',
                        ),
                        LandingBullet(
                          icon: Icons.new_releases_outlined,
                          title: 'Plan razvoja',
                          description:
                              'Dodavanje analitike po klijentu, eksport u XML/JPKD format i još mnogo toga.',
                        ),
                      ],
                    ),
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

