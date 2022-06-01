class User {
  final int id;
  final String username;
  final String email;
  final String? status;

  bool get isActive => status == 'active';

  User({
    required this.id,
    required this.username,
    required this.email,
    this.status,
  });

  User.fromJson(Map<dynamic, dynamic> json)
      : id = int.tryParse(json['id']?.toString() ?? '') ?? 0,
        username = json['username']?.toString() ?? '',
        email = json['email']?.toString() ?? '',
        status = json['status']?.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'status': status,
      };
}