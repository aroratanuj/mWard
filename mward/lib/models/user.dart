import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String role; // 'user' or 'admin'
  final String? wardCode;
  final DateTime createdAt;
  final DateTime? lastActive;

  User({
    required this.userId,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
    required this.role,
    this.wardCode,
    required this.createdAt,
    this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  User copyWith({
    String? userId,
    String? phoneNumber,
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    String? wardCode,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      wardCode: wardCode ?? this.wardCode,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
