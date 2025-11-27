import 'package:flutter/material.dart';

import '../widgets/landing_bullet.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final void Function(Locale)? onLanguageChange;

  const PrivacyPolicyPage({super.key, this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle),
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
            onPressed: () => Navigator.of(context).pushReplacementNamed('/app'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
            child: Text(l10n.launchApp),
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
                  l10n.privacyPolicyFullTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.privacyIntro,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionDataAccess,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                LandingBullet(
                  icon: Icons.person_outline,
                  title: l10n.privacyGoogleAccountTitle,
                  description: l10n.privacyGoogleAccountDesc,
                ),

                LandingBullet(
                  icon: Icons.table_chart_outlined,
                  title: l10n.privacyGoogleSheetsTitle,
                  description: l10n.privacyGoogleSheetsDesc,
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionScopes,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.privacyScopesDetails,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionDataUse,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.privacyDataUseDetails,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionDataProtection,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.privacyDataProtectionDetails,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionUserRights,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.privacyUserRightsDetails,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacySectionContact,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.privacyContactDetails,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),

                SelectableText(
                  l10n.privacyContactEmail,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  l10n.privacyLastUpdated,
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