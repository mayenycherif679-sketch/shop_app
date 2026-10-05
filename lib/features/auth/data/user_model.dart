import '../domain/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatar,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        avatar: j['avatar'] as String? ?? '',
        role: j['role'] as String? ?? 'customer',
      );
}
