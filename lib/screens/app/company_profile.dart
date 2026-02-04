class CompanyProfile {
  const CompanyProfile({
    required this.name,
    required this.shortName,
    required this.responsiblePerson,
    required this.pib,
    required this.address,
    required this.accountNumber,
    this.iban = '',
    this.swift = '',
  });

  final String name;
  final String shortName;
  final String responsiblePerson;
  final String pib;
  final String address;
  final String accountNumber;
  final String iban;
  final String swift;

  CompanyProfile copyWith({
    String? name,
    String? shortName,
    String? responsiblePerson,
    String? pib,
    String? address,
    String? accountNumber,
    String? iban,
    String? swift,
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      pib: pib ?? this.pib,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      swift: swift ?? this.swift,
    );
  }

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      responsiblePerson: json['responsiblePerson'] as String? ?? '',
      pib: json['pib'] as String? ?? '',
      address: json['address'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      iban: json['iban'] as String? ?? '',
      swift: json['swift'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'responsiblePerson': responsiblePerson,
      'pib': pib,
      'address': address,
      'accountNumber': accountNumber,
      'iban': iban,
      'swift': swift,
    };
  }
}
