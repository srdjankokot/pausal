class InvoiceItem {
  const InvoiceItem({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final String unit;
  final double quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  InvoiceItem copyWith({
    String? description,
    String? unit,
    double? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kom',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

