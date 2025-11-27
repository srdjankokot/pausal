import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/utils.dart';

class LedgerSection extends StatelessWidget {
  const LedgerSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.entries,
    required this.onRemove,
    required this.onEdit,
    required this.onShareInvoice,
    required this.onPrintInvoice,
    required this.findClient,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<LedgerEntry> entries;
  final void Function(String id) onRemove;
  final void Function(LedgerEntry entry) onEdit;
  final Future<void> Function(LedgerEntry entry) onShareInvoice;
  final Future<void> Function(LedgerEntry entry) onPrintInvoice;
  final Client? Function(String? id) findClient;

  @override
  Widget build(BuildContext context) {
    final grouped = groupEntriesByMonth(entries);

    return Card(
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Još uvek nema podataka. Dodajte novu stavku.'),
                )
              else
                ...grouped.entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ),
                      ...entry.value.map((item) {
                        final client = findClient(item.clientId);
                        final detailParts = <String>[];
                        if (item.isInvoice &&
                            item.invoiceNumber?.isNotEmpty == true) {
                          detailParts.add('Faktura ${item.invoiceNumber}');
                        }
                        detailParts.add(formatDate(item.date));
                        if (client != null) {
                          detailParts.add(client.name);
                        }
                        if (item.note?.isNotEmpty == true) {
                          detailParts.add(item.note!);
                        }

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => onRemove(item.id),
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => onEdit(item),
                            title: Text(item.title),
                            subtitle: Text(detailParts.join('  ·  ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildCurrencyText(
                                  context,
                                  item.amount,
                                  numberFontSize: 15,
                                  currencyFontSize: 9,
                                  numberWeight: FontWeight.bold,
                                  numberColor: Colors.black87,
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Radnje',
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      onEdit(item);
                                    } else if (value == 'delete') {
                                      onRemove(item.id);
                                    } else if (value == 'print') {
                                      await onPrintInvoice(item);
                                    } else if (value == 'share') {
                                      await onShareInvoice(item);
                                    }
                                  },
                                  itemBuilder: (menuContext) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Uredi'),
                                    ),
                                    if (item.isInvoice)
                                      const PopupMenuItem(
                                        value: 'print',
                                        child: Text('Štampa'),
                                      ),
                                    if (item.isInvoice)
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Text('PDF / Pošalji'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Obriši'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
