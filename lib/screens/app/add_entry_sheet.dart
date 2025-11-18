
import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/add_client.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/invoice_item.dart';
import 'package:pausal_calculator/screens/app/invoice_item_form_data.dart';
import 'package:pausal_calculator/screens/app/invoice_item_row.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/segment_option.dart';
import 'package:pausal_calculator/utils.dart';

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({
    super.key,
    required this.onSubmit,
    required this.clients,
    required this.onCreateClient,
    required this.existingEntries,
    this.initialEntry,
    this.onDelete,
  });

  final LedgerEntry? initialEntry;
  final void Function(LedgerEntry entry) onSubmit;
  final VoidCallback? onDelete;
  final List<Client> clients;
  final void Function(Client client) onCreateClient;
  final List<LedgerEntry> existingEntries;

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _clientSearchController;
  late LedgerKind _selectedKind;
  late DateTime _selectedDate;
  String? _selectedClientId;
  late List<InvoiceItemFormData> _invoiceItems;
  double _invoiceTotal = 0;
  late TextEditingController _invoiceNumberController;
  bool _invoiceNumberAutoFilled = false;

  bool get _isEditing => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEntry;
    _selectedKind = initial?.kind ?? LedgerKind.invoice;
    _selectedDate = initial?.date ?? DateTime.now();
    _titleController = TextEditingController(text: initial?.title ?? '');
    _amountController = TextEditingController(
      text: initial != null ? initial.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _clientSearchController = TextEditingController();
    _selectedClientId = initial?.clientId;
    _invoiceItems = <InvoiceItemFormData>[];
    if (_selectedKind == LedgerKind.invoice) {
      if (initial?.invoiceNumber?.trim().isNotEmpty == true) {
        _invoiceNumberController = TextEditingController(
          text: initial!.invoiceNumber!.trim(),
        );
        _invoiceNumberAutoFilled = false;
      } else {
        _invoiceNumberController = TextEditingController(
          text: _suggestInvoiceNumber(_selectedDate),
        );
        _invoiceNumberAutoFilled = true;
      }
    } else {
      _invoiceNumberController = TextEditingController(text: '');
      _invoiceNumberAutoFilled = true;
    }

    final hasClient =
        _selectedClientId != null &&
        widget.clients.any((client) => client.id == _selectedClientId);
    if (!hasClient) {
      _selectedClientId = null;
    }
    if (_selectedKind == LedgerKind.invoice &&
        _selectedClientId == null &&
        widget.clients.isNotEmpty) {
      _selectedClientId = widget.clients.first.id;
    }
    if (_selectedKind == LedgerKind.expense) {
      _selectedClientId = null;
    }
    _refreshClientSearchField();
    if (_selectedKind == LedgerKind.invoice) {
      _initializeInvoiceItems(initial);
    }
  }

  @override
  void didUpdateWidget(covariant AddEntrySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clients != widget.clients) {
      setState(_refreshClientSearchField);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _clientSearchController.dispose();
    _invoiceNumberController.dispose();
    for (final item in _invoiceItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (_selectedKind == LedgerKind.invoice && !_isEditing) {
        if (_invoiceNumberAutoFilled ||
            _invoiceNumberController.text.trim().isEmpty) {
          _invoiceNumberController.text = _suggestInvoiceNumber(picked);
          _invoiceNumberAutoFilled = true;
        }
      }
    }
  }

  Future<void> _createClient() async {
    final newClient = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return AddClientSheet(onSubmit: widget.onCreateClient);
      },
    );

    if (newClient != null) {
      setState(() {
        _selectedClientId = newClient.id;
        _clientSearchController.text = newClient.name;
      });
    }
  }

  void _initializeInvoiceItems(LedgerEntry? initial) {
    final existing = initial?.items ?? const [];
    if (existing.isNotEmpty) {
      _invoiceItems = existing
          .map(
            (item) => InvoiceItemFormData(
              description: item.description,
              unit: item.unit,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList();
    } else {
      final fallbackAmount = initial?.amount ?? 0;
      final fallbackDescription = initial?.title ?? '';
      _invoiceItems = [
        InvoiceItemFormData(
          description: fallbackDescription,
          unit: 'radni sat',
          quantity: 1,
          unitPrice: fallbackAmount > 0 ? fallbackAmount : 0,
        ),
      ];
    }
    _recalculateInvoiceTotal(updateText: true, notify: false);
  }

  void _ensureInvoiceItemsPresent() {
    if (_invoiceItems.isEmpty) {
      _invoiceItems = [
        InvoiceItemFormData(
          description: _titleController.text.trim(),
          unit: 'radni sat',
          quantity: 1,
          unitPrice: 0,
        ),
      ];
      _recalculateInvoiceTotal(updateText: true, notify: false);
    }
  }

  void _addInvoiceItem() {
    setState(() {
      _invoiceItems.add(InvoiceItemFormData());
      _recalculateInvoiceTotal(updateText: true, notify: false);
    });
  }

  void _removeInvoiceItem(int index) {
    if (_invoiceItems.length <= 1) {
      return;
    }
    setState(() {
      final removed = _invoiceItems.removeAt(index);
      removed.dispose();
      _recalculateInvoiceTotal(updateText: true, notify: false);
    });
  }

  void _recalculateInvoiceTotal({bool updateText = false, bool notify = true}) {
    final total = _invoiceItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    if (updateText) {
      _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';
    }
    if (notify) {
      setState(() {
        _invoiceTotal = total;
      });
    } else {
      _invoiceTotal = total;
    }
  }

  Client? _findClientById(String? id) {
    if (id == null) {
      return null;
    }
    for (final client in widget.clients) {
      if (client.id == id) {
        return client;
      }
    }
    return null;
  }

  void _refreshClientSearchField() {
    final client = _findClientById(_selectedClientId);
    _clientSearchController.text = client?.name ?? '';
  }

  Future<void> _openClientSearch() async {
    final result = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = widget.clients.where((client) {
              if (query.isEmpty) return true;
              final lower = query.toLowerCase();
              return client.name.toLowerCase().contains(lower) ||
                  client.pib.toLowerCase().contains(lower);
            }).toList()..sort((a, b) => a.name.compareTo(b.name));
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Pretraga klijenata',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setModalState(() {
                        query = value.trim();
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('Nema klijenata za zadati kriterijum.'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final client = filtered[index];
                            return ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(client.name),
                              subtitle: client.pib.isEmpty
                                  ? null
                                  : Text('PIB: ${client.pib}'),
                              onTap: () =>
                                  Navigator.of(sheetContext).pop(client),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedClientId = result.id;
        _clientSearchController.text = result.name;
      });
    }
  }

  String _suggestInvoiceNumber(DateTime date) {
    final excludeId = widget.initialEntry?.id;
    final count = widget.existingEntries.where((entry) {
      if (entry.kind != LedgerKind.invoice) return false;
      if (excludeId != null && entry.id == excludeId) return false;
      return entry.date.year == date.year;
    }).length;
    final next = count + 1;
    final numberPart = next.toString().padLeft(2, '0');
    return '$numberPart-${date.year}';
  }

  Widget _buildInvoiceItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stavke fakture',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addInvoiceItem,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj stavku'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_invoiceItems.length, (index) {
          final data = _invoiceItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InvoiceItemRow(
              index: index,
              data: data,
              onChanged: () => _recalculateInvoiceTotal(updateText: true),
              onRemove: _invoiceItems.length > 1
                  ? () => _removeInvoiceItem(index)
                  : null,
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Ukupno: ${formatCurrency(_invoiceTotal)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String? clientId;
    if (_selectedKind == LedgerKind.invoice) {
      clientId = _selectedClientId;
      if (clientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Odaberite klijenta za fakturu')),
        );
        return;
      }
    }

    double amount;
    List<InvoiceItem> invoiceItems = const [];
    if (_selectedKind == LedgerKind.invoice) {
      invoiceItems = _invoiceItems
          .map((item) => item.toInvoiceItem())
          .where(
            (item) =>
                item.description.trim().isNotEmpty &&
                item.quantity > 0 &&
                item.unitPrice > 0,
          )
          .toList();
      amount = invoiceItems.fold<double>(0, (sum, item) => sum + item.total);
      if (invoiceItems.isEmpty || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dodajte bar jednu stavku sa cenom i količinom.'),
          ),
        );
        return;
      }
      final numberValue = _invoiceNumberController.text.trim();
      if (numberValue.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unesite broj fakture.')));
        return;
      }
      _invoiceNumberAutoFilled = false;
    } else {
      final parsed = double.tryParse(
        _amountController.text.replaceAll(',', '.'),
      );
      if (parsed == null) {
        return;
      }
      amount = parsed;
    }

    final entry = LedgerEntry(
      id:
          widget.initialEntry?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      kind: _selectedKind,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      clientId: clientId,
      invoiceNumber: _selectedKind == LedgerKind.invoice
          ? _invoiceNumberController.text.trim()
          : null,
      items: _selectedKind == LedgerKind.invoice ? invoiceItems : const [],
    );

    widget.onSubmit(entry);
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final titleText = _isEditing ? 'Izmena stavke' : 'Nova stavka';
    final primaryActionLabel = _isEditing ? 'Sačuvaj izmene' : 'Sačuvaj stavku';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(minHeight: 44, minWidth: 120),
                isSelected: [
                  _selectedKind == LedgerKind.invoice,
                  _selectedKind == LedgerKind.expense,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedKind = LedgerKind.values[index];
                    if (_selectedKind == LedgerKind.expense) {
                      _selectedClientId = null;
                      _invoiceNumberController.text = '';
                      _invoiceNumberAutoFilled = true;
                      _clientSearchController.clear();
                      if (widget.initialEntry != null &&
                          widget.initialEntry!.kind == LedgerKind.expense) {
                        _amountController.text = widget.initialEntry!.amount
                            .toStringAsFixed(2);
                      } else if (!_isEditing) {
                        _amountController.clear();
                      }
                    } else {
                      if (_selectedClientId == null &&
                          widget.clients.isNotEmpty) {
                        _selectedClientId = widget.clients.first.id;
                      }
                      _ensureInvoiceItemsPresent();
                      _refreshClientSearchField();
                      if (!_isEditing ||
                          (widget.initialEntry?.invoiceNumber?.trim().isEmpty ??
                              true)) {
                        final suggestion = _suggestInvoiceNumber(_selectedDate);
                        _invoiceNumberController.text = suggestion;
                        _invoiceNumberAutoFilled = true;
                      } else {
                        _invoiceNumberAutoFilled = false;
                      }
                      _recalculateInvoiceTotal(updateText: true, notify: false);
                    }
                  });
                  if (_selectedKind == LedgerKind.invoice) {
                    _recalculateInvoiceTotal(updateText: true);
                  }
                },
                children: const [
                  SegmentOption(icon: Icons.trending_up, label: 'Prihod'),
                  SegmentOption(icon: Icons.trending_down, label: 'Trošak'),
                ],
              ),
              if (_selectedKind == LedgerKind.invoice) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clientSearchController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Klijent',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onTap: _openClientSearch,
                        validator: (_) {
                          if (_selectedClientId == null ||
                              _selectedClientId!.isEmpty) {
                            return 'Odaberite klijenta';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _createClient,
                      tooltip: 'Novi klijent',
                      icon: const Icon(Icons.person_add_alt),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Broj fakture',
                    hintText: 'npr. 10-2025',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _invoiceNumberAutoFilled = false,
                  validator: (value) {
                    if (_selectedKind != LedgerKind.invoice) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Unesite broj fakture';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _selectedKind == LedgerKind.invoice
                      ? 'Opis fakture'
                      : 'Naziv troška',
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unesite naziv';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedKind == LedgerKind.invoice) ...[
                _buildInvoiceItemsSection(context),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _amountController,
                readOnly: _selectedKind == LedgerKind.invoice,
                decoration: InputDecoration(
                  labelText: 'Ukupan iznos',
                  suffixText: 'RSD',
                  border: const OutlineInputBorder(),
                  helperText: _selectedKind == LedgerKind.invoice
                      ? 'Automatski se računa na osnovu stavki'
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (_selectedKind == LedgerKind.invoice) {
                    return null;
                  }
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) {
                    return 'Unesite iznos veći od nule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Datum',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(formatDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _pickDate,
                    tooltip: 'Izaberi datum',
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Napomena (opciono)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.onDelete != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.onDelete?.call();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Obriši'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(primaryActionLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
