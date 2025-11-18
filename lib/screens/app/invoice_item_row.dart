import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/invoice_item_form_data.dart';
import 'package:pausal_calculator/utils.dart';

class InvoiceItemRow extends StatelessWidget {
  const InvoiceItemRow({
    required this.index,
    required this.data,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final InvoiceItemFormData data;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalLabel = formatCurrency(data.total);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stavka ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Ukloni stavku',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: data.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis stavke',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite opis stavke';
                }
                return null;
              },
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: data.unitController,
                    builder: (context, value, _) {
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: const InputDecoration(
                          labelText: 'Jedinica mere',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'radni sat',
                            child: Text('Radni sat'),
                          ),
                          DropdownMenuItem(value: 'kom', child: Text('Komad')),
                        ],
                        onChanged: (selected) {
                          if (selected == null) return;
                          data.unitController.value = selected;
                          onChanged();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: data.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Količina',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite količinu';
                      }
                      return null;
                    },
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: data.unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Cena po jedinici',
                      suffixText: 'RSD',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite cenu';
                      }
                      return null;
                    },
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Iznos stavke: $totalLabel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

