
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/company_profile.dart';
import 'package:pausal_calculator/screens/app/invoice_item.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum SheetSyncTarget { entries, clients, profile }

Map<String, List<LedgerEntry>> groupEntriesByMonth(List<LedgerEntry> entries) {
  final sorted = entries.toList()..sort((a, b) => b.date.compareTo(a.date));
  final Map<String, List<LedgerEntry>> grouped = {};
  for (final entry in sorted) {
    final key = '${monthName(entry.date.month)} ${entry.date.year}';
    grouped.putIfAbsent(key, () => []).add(entry);
  }
  return grouped;
}

String monthName(int month) {
  const monthNames = [
    'januar',
    'februar',
    'mart',
    'april',
    'maj',
    'jun',
    'jul',
    'avgust',
    'septembar',
    'oktobar',
    'novembar',
    'decembar',
  ];
  return monthNames[month - 1];
}

String formatCurrency(double value) {
  final sign = value < 0 ? '-' : '';
  final absValue = value.abs();
  final parts = absValue.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];
  final separated = integerPart.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'RSD $sign$separated,$decimalPart';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year.';
}

pw.Font? _invoiceFontRegular;
pw.Font? _invoiceFontBold;

Future<void> ensureInvoiceFonts() async {
  _invoiceFontRegular ??= pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  _invoiceFontBold ??= pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
  );
}

Future<Uint8List> buildInvoicePdf(
  LedgerEntry entry,
  Client client,
  CompanyProfile company,
  TaxProfile profile,
) async {
  await ensureInvoiceFonts();
  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: _invoiceFontRegular!,
      bold: _invoiceFontBold!,
    ),
  );
  final issueDate = formatDate(entry.date);
  final dueDate = formatDate(entry.date.add(const Duration(days: 14)));
  final generatedOn = formatDate(DateTime.now());
  final amountText = formatCurrency(entry.amount);
  final noteText = entry.note?.trim().isNotEmpty == true
      ? entry.note!.trim()
      : '—';
  final inferredNumber =
      '${entry.date.month.toString().padLeft(2, '0')}-${entry.date.year}';
  final invoiceNumber = entry.invoiceNumber?.trim().isNotEmpty == true
      ? entry.invoiceNumber!.trim()
      : inferredNumber;
  // final shortTitle = company.shortName.trim().isNotEmpty
  //     ? company.shortName.trim()
  //     : '';
  // final fullTitle = company.name.trim().isNotEmpty
  //     ? company.name.trim()
  //     : '';

  final items = entry.items.isNotEmpty
      ? entry.items
      : [
          InvoiceItem(
            description: entry.title,
            unit: 'usluga',
            quantity: 1,
            unitPrice: entry.amount,
          ),
        ];
  String formatQuantity(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  String tableCurrency(double value) =>
      formatCurrency(value).replaceFirst('RSD ', '');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (company.shortName.isNotEmpty)
                      pw.Text(
                        company.shortName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                    if (company.name.isNotEmpty)
                      pw.Text(company.name, style: pw.TextStyle(fontSize: 10)),

                    if (company.address.isNotEmpty)
                      pw.Text(
                        company.address,
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    pw.Text(
                      profile.city,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(width: 24),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (company.pib.isNotEmpty)
                      pw.Text(
                        'PIB: ${company.pib}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (company.accountNumber.isNotEmpty)
                      pw.Text(
                        'T.R.: ${company.accountNumber}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    // pw.Text('Datum izrade: $generatedOn',
                    //     style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Faktura br.: $invoiceNumber',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Datum računa: $issueDate',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'Datum dospeća: $dueDate',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    '${profile.city}, ${issueDate}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Kupac',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Text(client.name, style: const pw.TextStyle(fontSize: 12)),
                if (client.pib.isNotEmpty)
                  pw.Text(
                    'PIB: ${client.pib}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                if (client.address.isNotEmpty)
                  pw.Text(
                    client.address,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
            columnWidths: {
              0: const pw.FixedColumnWidth(32),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1.4),
              5: const pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'R.br',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Vrsta robe / usluge',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Container(
                      width: 50,
                      child: pw.Text(
                        'Jedinica mere',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Količina',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Cena / jedinici (RSD)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Ukupno (RSD)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...items.asMap().entries.map((itemEntry) {
                final index = itemEntry.key + 1;
                final item = itemEntry.value;
                final description = item.description.trim().isEmpty
                    ? '—'
                    : item.description;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(index.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(description),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.unit),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(formatQuantity(item.quantity)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(tableCurrency(item.unitPrice)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(tableCurrency(item.total)),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'IZNOS UKUPNO  $amountText',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Divider(height: 1, thickness: 1),
          pw.SizedBox(height: 6),
          pw.Text(
            'Izdavalac računa nije obveznik PDV-a po članu 33. zakona o PDV',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            'Izdavalac računa je paušalni obveznik poreza po članu 42. Zakona o porezu na dohodak',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),

          if (noteText != '—') ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Dodatna napomena:',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(noteText, style: const pw.TextStyle(fontSize: 10)),
          ],

          pw.SizedBox(height: 12),
          pw.Text(
            'Način plaćanja: Virman',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Valuta plaćanja: 14 dana',
            style: const pw.TextStyle(fontSize: 11),
          ),

          pw.SizedBox(height: 12),
          pw.Text(
            'Uplatu izvršiti na račun: ${company.accountNumber}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            'Poziv na broj: $invoiceNumber',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // pw.Text('Obračun doprinosa (mesečno):',
                  //     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  // pw.Text(
                  //   'PIO: ${formatCurrency(profile.monthlyPension)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                  // pw.Text(
                  //   'Zdravstveno: ${formatCurrency(profile.monthlyHealth)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                  // pw.Text(
                  //   'Akontacija poreza: ${formatCurrency(profile.monthlyTaxPrepayment)}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Odgovorno lice',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    width: 160,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey500, width: 1),
                      ),
                    ),
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      company.responsiblePerson.isNotEmpty
                          ? company.responsiblePerson
                          : (company.shortName.isNotEmpty
                                ? company.shortName
                                : company.name),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
        ],
      ),
    ),
  );

  return pdf.save();
}

String sanitizeFileName(String input) {
  final fallback = input.isEmpty ? 'faktura' : input;
  final sanitized = fallback
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return sanitized.isEmpty ? 'faktura' : sanitized;
}

String? validatePositiveNumber(String? value) {
  final sanitized = value?.replaceAll(',', '.');
  final parsed = double.tryParse(sanitized ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Unesite broj veći od nule';
  }
  return null;
}

