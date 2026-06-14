// lib/data/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:nutricare_elderly/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    String? phone,
    String? gender,
    required DateTime createdAt,
  }) : super(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    age: age,
    phone: phone,
    gender: gender,
    createdAt: createdAt,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    firstName: entity.firstName,
    lastName: entity.lastName,
    age: entity.age,
    phone: entity.phone,
    gender: entity.gender,
    createdAt: entity.createdAt,
  );
}
