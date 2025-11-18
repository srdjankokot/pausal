
import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/invoice_item.dart';

class InvoiceItemFormData {
  InvoiceItemFormData({
    String description = '',
    String unit = 'radni sat',
    double quantity = 1,
    double unitPrice = 0,
  }) : descriptionController = TextEditingController(text: description),
       unitController = ValueNotifier<String>(unit),
       quantityController = TextEditingController(
         text: quantity > 0 ? _formatNumber(quantity) : '',
       ),
       unitPriceController = TextEditingController(
         text: unitPrice > 0 ? unitPrice.toStringAsFixed(2) : '',
       );

  final TextEditingController descriptionController;
  final ValueNotifier<String> unitController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  double get quantity =>
      double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
  double get unitPrice =>
      double.tryParse(unitPriceController.text.replaceAll(',', '.')) ?? 0;
  double get total => quantity * unitPrice;

  String get unit =>
      unitController.value.trim().isEmpty ? 'jed' : unitController.value.trim();

  InvoiceItem toInvoiceItem() {
    return InvoiceItem(
      description: descriptionController.text.trim(),
      unit: unit,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }

  void dispose() {
    descriptionController.dispose();
    unitController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }

  static String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
