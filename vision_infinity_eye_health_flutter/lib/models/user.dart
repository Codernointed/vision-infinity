import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final DateTime createdAt;
  final List<String> roles;
  final Map<String, dynamic> preferences;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    required this.createdAt,
    required this.roles,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
