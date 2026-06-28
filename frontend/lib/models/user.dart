class UserModel {
  final String id;
  final String name;
  final String mobile;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? '',
    );
  }

  bool get isOwner => role == 'owner';
  bool get isLabour => role == 'labour';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'role': role,
      };
}
