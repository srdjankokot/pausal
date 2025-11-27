import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final isWideLayout = mediaQuery.size.width >= 900;


    final l10n = AppLocalizations.of(context)!;
    final sortedClients = clients.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final invoices = entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final invoiceCountByClient = <String, int>{};
    for (final invoice in invoices) {
      final clientId = invoice.clientId;
      if (clientId == null) continue;
      invoiceCountByClient.update(clientId, (value) => value + 1, ifAbsent: () => 1);
    }

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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: clients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noClientsYet,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: onAddClient,
                            icon: const Icon(Icons.person_add),
                            label: Text(l10n.addFirstClient),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [

                      if(isWideLayout)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Naziv',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'PIB',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Adresa',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                      if(isWideLayout)
                      const SizedBox(height: 12),
                      
                      if(isWideLayout)
                      Divider(height: 1, color: Colors.grey[300]),

                      const SizedBox(height: 8),
                      ...sortedClients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final client = entry.value;
                        final invoiceCount = invoiceCountByClient[client.id] ?? 0;
                        final isLast = index == sortedClients.length - 1;


                        if(isWideLayout){
                      return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          client.name,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (invoiceCount > 0)
                                          Text(
                                            '$invoiceCount faktura',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      client.pib.isEmpty ? l10n.pibNotAvailable : client.pib,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      client.address.isEmpty ? '-' : client.address,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        onEditClient(client);
                                      } else if (value == 'delete') {
                                        onDeleteClient(client.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.more_vert, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) Divider(height: 1, color: Colors.grey[200]),
                          ],
                        );
                        }

                        else
                         {
                          return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: 
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                        Text(
                                          client.name,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    
                                    Text(
                                      client.address.isEmpty ? '-' : client.address,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Text(
                                      client.pib.isEmpty ? l10n.pibNotAvailable : client.pib,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  
                                   
                                    if (invoiceCount > 0)
                                          Text(
                                            '$invoiceCount faktura',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),



                                  ]),
                                  ),
                                  
                                  
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        onEditClient(client);
                                      } else if (value == 'delete') {
                                        onDeleteClient(client.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.more_vert, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) Divider(height: 1, color: Colors.grey[200]),
                          ],
                        );
                         }


                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
