import 'package:flutter/material.dart';
import 'package:pausal_calculator/constants/app_constants.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/utils.dart';
import 'package:pausal_calculator/l10n/app_localizations.dart';

class LedgerTab extends StatefulWidget {
  const LedgerTab({
    super.key,
    required this.entries,
    required this.clients,
    required this.onRemove,
    required this.onEdit,
    required this.onShareInvoice,
    required this.onPrintInvoice,
    required this.findClient,
  });

  final List<LedgerEntry> entries;
  final List<Client> clients;
  final void Function(String id) onRemove;
  final void Function(LedgerEntry entry) onEdit;
  final Future<void> Function(LedgerEntry entry) onShareInvoice;
  final Future<void> Function(LedgerEntry entry) onPrintInvoice;
  final Client? Function(String? id) findClient;

  @override
  State<LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String? _selectedClientId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedDateRange != null || _selectedClientId != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invoices = widget.entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .where(_matchesFilters)
        .toList();
    final expenses = widget.entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .where(_matchesFilters)
        .toList();

    // Sort by date, newest first
    invoices.sort((a, b) => b.date.compareTo(a.date));
    expenses.sort((a, b) => b.date.compareTo(a.date));

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ledgerPageTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ledgerPageSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 20),
                // Tab bar for Prihod/Rashod
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IntrinsicWidth(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        color: darkNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[700],
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      labelPadding: EdgeInsets.zero,
                      tabs: const [
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text('Prihod'),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Text('Trošak'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _buildFilterSection(l10n),
          ),
          // Table section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTableView(invoices, isInvoice: true, l10n: l10n),
                _buildTableView(expenses, isInvoice: false, l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(LedgerEntry entry) {
    final matchesDateRange = _selectedDateRange == null ||
        (entry.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
    final matchesClient =
        _selectedClientId == null || entry.clientId == _selectedClientId;
    return matchesDateRange && matchesClient;
  }

  Widget _buildFilterSection(AppLocalizations l10n) {
    const double filterHeight = 36.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Date range picker
          SizedBox(
            height: filterHeight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _selectedDateRange,
                  useRootNavigator: false,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: darkNavy,
                        ),
                        dialogTheme: const DialogThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                            maxHeight: 550,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                  });
                }
              },
              icon: Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
              label: Text(
                _selectedDateRange == null
                    ? l10n.selectPeriod
                    : '${formatDate(_selectedDateRange!.start)} - ${formatDate(_selectedDateRange!.end)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Client dropdown
          Container(
            height: filterHeight,
            constraints: const BoxConstraints(minWidth: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedClientId,
                isDense: true,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700], size: 20),
                hint: Text(
                  l10n.allClients,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.allClients),
                  ),
                  ...widget.clients.map(
                    (client) => DropdownMenuItem<String?>(
                      value: client.id,
                      child: Text(client.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedClientId = value;
                  });
                },
              ),
            ),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: filterHeight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDateRange = null;
                    _selectedClientId = null;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  l10n.clearFilters,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableView(
    List<LedgerEntry> entries, {
    required bool isInvoice,
    required AppLocalizations l10n,
  }) {
    if (entries.isEmpty) {
      return Container(
        color: Colors.grey[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.noDataYet,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Container(

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        l10n.clientName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'PIB',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.invoiceNumberShort,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
               Expanded(
                      flex: 3,
                      child: Text(
                        'Opis',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),


                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.issueDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.invoiceAmount,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Space for menu button
                  ],
                ),
              ),
              // Table rows
              ...entries.map((entry) => _buildTableRow(entry, isInvoice, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    LedgerEntry entry,
    bool isInvoice,
    AppLocalizations l10n,
  ) {
    final client = widget.findClient(entry.clientId);

    return InkWell(
      onTap: () => widget.onEdit(entry),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // Client name
            Expanded(
              flex: 3,
              child: Text(
                isInvoice
                    ? (client?.name ?? l10n.unknownClient)
                    : entry.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // PIB
            Expanded(
              flex: 2,
              child: Text(
                client?.pib ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            // Invoice number
            Expanded(
              flex: 2,
              child: Text(
                isInvoice ? (entry.invoiceNumber ?? '-') : '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

           Expanded(
              flex: 3,
              child: Text(
                isInvoice ? (entry.title) : '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                formatDate(entry.date),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            // Amount
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: buildCurrencyText(
                  context,
                  entry.amount,
                  numberFontSize: 14,
                  currencyFontSize: 9,
                  numberWeight: FontWeight.w600,
                  numberColor: isInvoice ? Colors.green[600]! : Colors.red[600]!,
                  currency: entry.currency,
                ),
              ),
            ),
            // Menu button
            PopupMenuButton<String>(
              tooltip: 'Radnje',
              onSelected: (value) async {
                if (value == 'edit') {
                  widget.onEdit(entry);
                } else if (value == 'delete') {
                  widget.onRemove(entry.id);
                } else if (value == 'print') {
                  await widget.onPrintInvoice(entry);
                } else if (value == 'share') {
                  await widget.onShareInvoice(entry);
                }
              },
              itemBuilder: (menuContext) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Uredi'),
                ),
                if (entry.isInvoice)
                  const PopupMenuItem(
                    value: 'print',
                    child: Text('Štampa'),
                  ),
                if (entry.isInvoice)
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
  }
}
