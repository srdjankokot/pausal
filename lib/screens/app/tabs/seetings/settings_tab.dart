import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/company_profile.dart';
import 'package:pausal_calculator/screens/app/google_sheet_card.dart';
import 'package:pausal_calculator/screens/app/profile_form.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';

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
          GoogleSheetsCard(
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
              child: ProfileForm(
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
