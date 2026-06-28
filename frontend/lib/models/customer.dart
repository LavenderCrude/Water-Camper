class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double pendingAmount;
  final bool active;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.pendingAmount,
    required this.active,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'pendingAmount': pendingAmount,
        'active': active,
      };
}
