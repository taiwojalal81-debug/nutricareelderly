// lib/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String? phone;
  final String? gender;
  final String? emergencyContact;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.phone,
    this.gender,
    this.emergencyContact,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        age,
        phone,
        gender,
        emergencyContact,
        avatarUrl,
        createdAt,
      ];
}
