class Client {
  const Client({
    required this.id,
    required this.name,
    required this.pib,
    required this.address,
    this.isForeign = false,
  });

  final String id;
  final String name;
  final String pib;
  final String address;
  final bool isForeign;

  Client copyWith({String? name, String? pib, String? address, bool? isForeign}) {
    return Client(
      id: id,
      name: name ?? this.name,
      pib: pib ?? this.pib,
      address: address ?? this.address,
      isForeign: isForeign ?? this.isForeign,
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pib: json['pib'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isForeign: json['isForeign'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'pib': pib, 'address': address, 'isForeign': isForeign};
  }
}
