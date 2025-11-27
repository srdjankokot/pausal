import 'package:flutter/material.dart';
import 'package:pausal_calculator/utils.dart';

class ContributionRow extends StatelessWidget {
  const ContributionRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        buildCurrencyText(
          context,
          value,
          numberFontSize: emphasize ? 16 : 15,
          currencyFontSize: emphasize ? 10 : 9,
          numberWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          numberColor: Colors.black87,
        ),
      ],
    );
  }
}

