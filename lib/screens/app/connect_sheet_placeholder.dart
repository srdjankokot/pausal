import 'package:flutter/material.dart';

class ConnectSheetPlaceholder extends StatelessWidget {
  const ConnectSheetPlaceholder({
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

