// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  profileImage: json['profileImage'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  preferences: json['preferences'] as Map<String, dynamic>,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'profileImage': instance.profileImage,
  'createdAt': instance.createdAt.toIso8601String(),
  'roles': instance.roles,
  'preferences': instance.preferences,
};
