import 'package:pausal_calculator/screens/app/yearly_tax_rates.dart';

class TaxProfile {
  const TaxProfile({
    required this.city,
    required this.monthlyPension,
    required this.monthlyHealth,
    required this.monthlyTaxPrepayment,
    required this.monthlyUnemployment,
    required this.annualLimit,
    required this.rollingLimit,
    required this.additionalTaxRate,
    this.yearlyRates = const {},
  });

  final String city;
  final double monthlyPension;
  final double monthlyHealth;
  final double monthlyTaxPrepayment;
  final double monthlyUnemployment;
  final double annualLimit;
  final double rollingLimit;
  final double additionalTaxRate;
  final Map<int, YearlyTaxRates> yearlyRates;

  double get monthlyFixedContributions =>
      ratesForYear(DateTime.now().year).monthlyTotal;

  YearlyTaxRates ratesForYear(int year) {
    if (yearlyRates.containsKey(year)) return yearlyRates[year]!;
    final previousYears = yearlyRates.keys.where((y) => y < year).toList()
      ..sort();
    if (previousYears.isNotEmpty) return yearlyRates[previousYears.last]!;
    return YearlyTaxRates(
      year: year,
      monthlyPension: monthlyPension,
      monthlyHealth: monthlyHealth,
      monthlyTaxPrepayment: monthlyTaxPrepayment,
      monthlyUnemployment: monthlyUnemployment,
    );
  }

  TaxProfile copyWith({
    String? city,
    double? monthlyPension,
    double? monthlyHealth,
    double? monthlyTaxPrepayment,
    double? monthlyUnemployment,
    double? annualLimit,
    double? rollingLimit,
    double? additionalTaxRate,
    Map<int, YearlyTaxRates>? yearlyRates,
  }) {
    return TaxProfile(
      city: city ?? this.city,
      monthlyPension: monthlyPension ?? this.monthlyPension,
      monthlyHealth: monthlyHealth ?? this.monthlyHealth,
      monthlyTaxPrepayment: monthlyTaxPrepayment ?? this.monthlyTaxPrepayment,
      monthlyUnemployment: monthlyUnemployment ?? this.monthlyUnemployment,
      annualLimit: annualLimit ?? this.annualLimit,
      rollingLimit: rollingLimit ?? this.rollingLimit,
      additionalTaxRate: additionalTaxRate ?? this.additionalTaxRate,
      yearlyRates: yearlyRates ?? this.yearlyRates,
    );
  }

  factory TaxProfile.fromJson(
    Map<String, dynamic> json, {
    Map<int, YearlyTaxRates>? yearlyRates,
  }) {
    final pension = (json['monthlyPension'] as num?)?.toDouble() ?? 0;
    final health = (json['monthlyHealth'] as num?)?.toDouble() ?? 0;
    final taxPrepayment =
        (json['monthlyTaxPrepayment'] as num?)?.toDouble() ?? 0;
    final unemployment =
        (json['monthlyUnemployment'] as num?)?.toDouble() ?? 0;

    Map<int, YearlyTaxRates> rates = yearlyRates ?? {};
    if (rates.isEmpty &&
        (pension > 0 || health > 0 || taxPrepayment > 0 || unemployment > 0)) {
      final currentYear = DateTime.now().year;
      rates = {
        currentYear: YearlyTaxRates(
          year: currentYear,
          monthlyPension: pension,
          monthlyHealth: health,
          monthlyTaxPrepayment: taxPrepayment,
          monthlyUnemployment: unemployment,
        ),
      };
    }

    return TaxProfile(
      city: json['city'] as String? ?? '',
      monthlyPension: pension,
      monthlyHealth: health,
      monthlyTaxPrepayment: taxPrepayment,
      monthlyUnemployment: unemployment,
      annualLimit: (json['annualLimit'] as num?)?.toDouble() ?? 0,
      rollingLimit: (json['rollingLimit'] as num?)?.toDouble() ?? 0,
      additionalTaxRate: (json['additionalTaxRate'] as num?)?.toDouble() ?? 0,
      yearlyRates: rates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'monthlyPension': monthlyPension,
      'monthlyHealth': monthlyHealth,
      'monthlyTaxPrepayment': monthlyTaxPrepayment,
      'monthlyUnemployment': monthlyUnemployment,
      'annualLimit': annualLimit,
      'rollingLimit': rollingLimit,
      'additionalTaxRate': additionalTaxRate,
    };
  }

  Map<int, Map<String, dynamic>> yearlyRatesToJson() {
    return yearlyRates.map(
      (year, rates) => MapEntry(year, rates.toJson()),
    );
  }
}
