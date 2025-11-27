import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/client_share.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/utils.dart';
import 'package:pausal_calculator/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
      return ClientShare(
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
                l10n.clients,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: onAddClient,
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.newClient),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.clientLimitNote,
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
                  Text(l10n.noClientsYet),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onAddClient,
                    icon: const Icon(Icons.person_add),
                    label: Text(l10n.addFirstClient),
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
                        '${l10n.pibLabel}${stat.client.pib.isEmpty ? l10n.pibNotAvailable : stat.client.pib}',
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
                        l10n.clientStats(percent.toStringAsFixed(1), invoiceCount, formatCurrency(stat.amount)),
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
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.delete),
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
