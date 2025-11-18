
class TaxProfile {
  const TaxProfile({
    required this.city,
    required this.monthlyPension,
    required this.monthlyHealth,
    required this.monthlyTaxPrepayment,
    required this.annualLimit,
    required this.rollingLimit,
    required this.additionalTaxRate,
  });

  final String city;
  final double monthlyPension;
  final double monthlyHealth;
  final double monthlyTaxPrepayment;
  final double annualLimit;
  final double rollingLimit;
  final double additionalTaxRate;

  double get monthlyFixedContributions =>
      monthlyPension + monthlyHealth + monthlyTaxPrepayment;

  TaxProfile copyWith({
    String? city,
    double? monthlyPension,
    double? monthlyHealth,
    double? monthlyTaxPrepayment,
    double? annualLimit,
    double? rollingLimit,
    double? additionalTaxRate,
  }) {
    return TaxProfile(
      city: city ?? this.city,
      monthlyPension: monthlyPension ?? this.monthlyPension,
      monthlyHealth: monthlyHealth ?? this.monthlyHealth,
      monthlyTaxPrepayment: monthlyTaxPrepayment ?? this.monthlyTaxPrepayment,
      annualLimit: annualLimit ?? this.annualLimit,
      rollingLimit: rollingLimit ?? this.rollingLimit,
      additionalTaxRate: additionalTaxRate ?? this.additionalTaxRate,
    );
  }

  factory TaxProfile.fromJson(Map<String, dynamic> json) {
    return TaxProfile(
      city: json['city'] as String? ?? '',
      monthlyPension: (json['monthlyPension'] as num?)?.toDouble() ?? 0,
      monthlyHealth: (json['monthlyHealth'] as num?)?.toDouble() ?? 0,
      monthlyTaxPrepayment:
          (json['monthlyTaxPrepayment'] as num?)?.toDouble() ?? 0,
      annualLimit: (json['annualLimit'] as num?)?.toDouble() ?? 0,
      rollingLimit: (json['rollingLimit'] as num?)?.toDouble() ?? 0,
      additionalTaxRate: (json['additionalTaxRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'monthlyPension': monthlyPension,
      'monthlyHealth': monthlyHealth,
      'monthlyTaxPrepayment': monthlyTaxPrepayment,
      'annualLimit': annualLimit,
      'rollingLimit': rollingLimit,
      'additionalTaxRate': additionalTaxRate,
    };
  }
}

