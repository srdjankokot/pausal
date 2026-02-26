class YearlyTaxRates {
  const YearlyTaxRates({
    required this.year,
    this.monthlyPension = 0,
    this.monthlyHealth = 0,
    this.monthlyTaxPrepayment = 0,
    this.monthlyUnemployment = 0,
  });

  final int year;
  final double monthlyPension;
  final double monthlyHealth;
  final double monthlyTaxPrepayment;
  final double monthlyUnemployment;

  double get monthlyTotal =>
      monthlyPension + monthlyHealth + monthlyTaxPrepayment + monthlyUnemployment;

  YearlyTaxRates copyWith({
    int? year,
    double? monthlyPension,
    double? monthlyHealth,
    double? monthlyTaxPrepayment,
    double? monthlyUnemployment,
  }) {
    return YearlyTaxRates(
      year: year ?? this.year,
      monthlyPension: monthlyPension ?? this.monthlyPension,
      monthlyHealth: monthlyHealth ?? this.monthlyHealth,
      monthlyTaxPrepayment: monthlyTaxPrepayment ?? this.monthlyTaxPrepayment,
      monthlyUnemployment: monthlyUnemployment ?? this.monthlyUnemployment,
    );
  }

  factory YearlyTaxRates.fromJson(Map<String, dynamic> json) {
    return YearlyTaxRates(
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      monthlyPension: (json['monthlyPension'] as num?)?.toDouble() ?? 0,
      monthlyHealth: (json['monthlyHealth'] as num?)?.toDouble() ?? 0,
      monthlyTaxPrepayment:
          (json['monthlyTaxPrepayment'] as num?)?.toDouble() ?? 0,
      monthlyUnemployment:
          (json['monthlyUnemployment'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'monthlyPension': monthlyPension,
      'monthlyHealth': monthlyHealth,
      'monthlyTaxPrepayment': monthlyTaxPrepayment,
      'monthlyUnemployment': monthlyUnemployment,
    };
  }
}
