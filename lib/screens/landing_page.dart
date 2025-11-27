import 'package:flutter/material.dart';

import '../widgets/landing_bullet.dart';
import '../l10n/app_localizations.dart';

class LandingPage extends StatelessWidget {
  final void Function(Locale)? onLanguageChange;

  const LandingPage({super.key, this.onLanguageChange});

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          // Language selector
          PopupMenuButton<Locale>(
            tooltip: 'Language / Jezik',
            icon: const Icon(Icons.language),
            onSelected: (locale) => onLanguageChange?.call(locale),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('sr', ''),
                child: Text('🇷🇸 Srpski'),
              ),
              const PopupMenuItem(
                value: Locale('en', ''),
                child: Text('🇬🇧 English'),
              ),
            ],
          ),
          TextButton(
            onPressed: () => _openPrivacyPolicy(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
            child: Text(l10n.privacyPolicy),
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
                  l10n.landingTitle,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.landingSubtitle,
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
                      label: Text(l10n.launchApp),
                    ),
                    OutlinedButton(
                      onPressed: () => _openPrivacyPolicy(context),
                      child: Text(l10n.privacyPolicy),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.whatAppDoes,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LandingBullet(
                          icon: Icons.dashboard_customize,
                          title: l10n.featureOverviewTitle,
                          description: l10n.featureOverviewDesc,
                        ),
                        LandingBullet(
                          icon: Icons.people_outline,
                          title: l10n.featureClientsTitle,
                          description: l10n.featureClientsDesc,
                        ),
                        LandingBullet(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.featureInvoicingTitle,
                          description: l10n.featureInvoicingDesc,
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
                        Text(
                          l10n.whatsNew,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LandingBullet(
                          icon: Icons.cloud_done_outlined,
                          title: l10n.featureSyncTitle,
                          description: l10n.featureSyncDesc,
                        ),
                        LandingBullet(
                          icon: Icons.check_circle_outline,
                          title: l10n.featureOnboardingTitle,
                          description: l10n.featureOnboardingDesc,
                        ),
                        LandingBullet(
                          icon: Icons.security_outlined,
                          title: l10n.featureDataControlTitle,
                          description: l10n.featureDataControlDesc,
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
                        Text(
                          l10n.importantLinks,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LandingBullet(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.linkPrivacyTitle,
                          description: l10n.linkPrivacyDesc,
                        ),
                        LandingBullet(
                          icon: Icons.mail_outline,
                          title: l10n.linkSupportTitle,
                          description: l10n.linkSupportDesc,
                        ),
                        LandingBullet(
                          icon: Icons.new_releases_outlined,
                          title: l10n.linkRoadmapTitle,
                          description: l10n.linkRoadmapDesc,
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

