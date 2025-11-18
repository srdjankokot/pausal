
import 'package:flutter/material.dart';
import 'package:pausal_calculator/constants/app_constants.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/tabs/ledger/ledger_section.dart';
import 'package:pausal_calculator/utils.dart';

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

class _LedgerTabState extends State<LedgerTab> {
  int? _selectedYear;
  int? _selectedMonth;
  String? _selectedClientId;

  bool get _hasActiveFilters =>
      _selectedYear != null ||
      _selectedMonth != null ||
      _selectedClientId != null;

  @override
  Widget build(BuildContext context) {
    final invoices = widget.entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final filteredInvoices = invoices.where(_matchesFilters).toList();
    final expenses = widget.entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          if (invoices.isNotEmpty) _buildFilterCard(invoices),
          if (invoices.isNotEmpty) const SizedBox(height: 16),
          LedgerSection(
            title: 'Izdati računi',
            icon: Icons.trending_up,
            iconColor: Colors.green[600]!,
            entries: filteredInvoices,
            onRemove: widget.onRemove,
            onEdit: widget.onEdit,
            onShareInvoice: widget.onShareInvoice,
            onPrintInvoice: widget.onPrintInvoice,
            findClient: widget.findClient,
          ),
          const SizedBox(height: 24),
          LedgerSection(
            title: 'Troškovi',
            icon: Icons.trending_down,
            iconColor: pastelBlueDark,
            entries: expenses,
            onRemove: widget.onRemove,
            onEdit: widget.onEdit,
            onShareInvoice: widget.onShareInvoice,
            onPrintInvoice: widget.onPrintInvoice,
            findClient: widget.findClient,
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(LedgerEntry entry) {
    final matchesYear =
        _selectedYear == null || entry.date.year == _selectedYear;
    final matchesMonth =
        _selectedMonth == null || entry.date.month == _selectedMonth;
    final matchesClient =
        _selectedClientId == null || entry.clientId == _selectedClientId;
    return matchesYear && matchesMonth && matchesClient;
  }

  Widget _buildFilterCard(List<LedgerEntry> invoices) {
    final years = invoices.map((e) => e.date.year).toSet().toList()..sort();
    final months = _availableMonths(invoices, _selectedYear);
    final clientItems = widget.clients
        .map(
          (client) => DropdownMenuItem<String?>(
            value: client.id,
            child: Text(client.name),
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filteri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedYear = null;
                        _selectedMonth = null;
                        _selectedClientId = null;
                      });
                    },
                    child: const Text('Obriši filtere'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Godina',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Sve godine'),
                      ),
                      ...years.map(
                        (year) => DropdownMenuItem<int?>(
                          value: year,
                          child: Text(year.toString()),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        final available = _availableMonths(invoices, value);
                        if (_selectedMonth != null &&
                            !available.contains(_selectedMonth)) {
                          _selectedMonth = null;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Mesec',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Svi meseci'),
                      ),
                      ...months.map(
                        (month) => DropdownMenuItem<int?>(
                          value: month,
                          child: Text(monthName(month)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Klijent',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Svi klijenti'),
                      ),
                      ...clientItems,
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<int> _availableMonths(List<LedgerEntry> invoices, int? year) {
    final filtered =
        invoices
            .where((invoice) {
              if (year == null) return true;
              return invoice.date.year == year;
            })
            .map((invoice) => invoice.date.month)
            .toSet()
            .toList()
          ..sort();
    return filtered;
  }
}
