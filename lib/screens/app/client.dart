class Client {
  const Client({
    required this.id,
    required this.name,
    required this.pib,
    required this.address,
  });

  final String id;
  final String name;
  final String pib;
  final String address;

  Client copyWith({String? name, String? pib, String? address}) {
    return Client(
      id: id,
      name: name ?? this.name,
      pib: pib ?? this.pib,
      address: address ?? this.address,
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pib: json['pib'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'pib': pib, 'address': address};
  }
}
