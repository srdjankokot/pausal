import 'dart:convert';

import 'package:pausal_calculator/screens/app/invoice_item.dart';

enum LedgerKind { invoice, expense }

class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
    this.clientId,
    this.invoiceNumber,
    List<InvoiceItem>? items,
  }) : items = List<InvoiceItem>.unmodifiable(items ?? const []);

  final String id;
  final LedgerKind kind;
  final String title;
  final double amount;
  final DateTime date;
  final String? note;
  final String? clientId;
  final String? invoiceNumber;
  final List<InvoiceItem> items;

  bool get isInvoice => kind == LedgerKind.invoice;
  double get totalFromItems =>
      items.fold<double>(0, (sum, item) => sum + item.total);

  LedgerEntry copyWith({
    LedgerKind? kind,
    String? title,
    double? amount,
    DateTime? date,
    String? note,
    bool clearNote = false,
    String? clientId,
    bool clearClient = false,
    String? invoiceNumber,
    List<InvoiceItem>? items,
  }) {
    return LedgerEntry(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
      clientId: clearClient ? null : (clientId ?? this.clientId),
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    final kindValue = json['kind'] as String? ?? LedgerKind.invoice.name;
    final kind = LedgerKind.values.firstWhere(
      (value) => value.name == kindValue,
      orElse: () => LedgerKind.invoice,
    );
    final parsedItems = _parseInvoiceItems(json['items']);
    final baseAmount = (json['amount'] as num?)?.toDouble() ?? 0;
    final computedAmount = parsedItems.isNotEmpty
        ? parsedItems.fold<double>(0, (sum, item) => sum + item.total)
        : baseAmount;
    final rawInvoiceNumber = json['invoiceNumber'] as String?;
    final normalizedInvoiceNumber =
        rawInvoiceNumber != null && rawInvoiceNumber.trim().isNotEmpty
        ? rawInvoiceNumber.trim()
        : null;
    return LedgerEntry(
      id: json['id'] as String? ?? '',
      kind: kind,
      title: json['title'] as String? ?? '',
      amount: computedAmount,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
      clientId: json['clientId'] as String?,
      invoiceNumber: normalizedInvoiceNumber,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'clientId': clientId,
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  static List<InvoiceItem> _parseInvoiceItems(dynamic raw) {
    if (raw == null) {
      return const [];
    }
    try {
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .where((element) => element is Map)
              .map(
                (element) => InvoiceItem.fromJson(
                  Map<String, dynamic>.from(element as Map),
                ),
              )
              .toList();
        }
      } else if (raw is List) {
        return raw
            .where((element) => element is Map)
            .map(
              (element) => InvoiceItem.fromJson(
                Map<String, dynamic>.from(element as Map),
              ),
            )
            .toList();
      }
    } catch (_) {
      // ignore malformed data
    }
    return const [];
  }
}
