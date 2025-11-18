
import 'package:flutter/material.dart';

class GoogleSheetsCard extends StatelessWidget {
  const GoogleSheetsCard({
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
