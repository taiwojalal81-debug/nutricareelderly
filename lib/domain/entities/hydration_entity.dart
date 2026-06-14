// lib/domain/entities/hydration_entity.dart

import 'package:equatable/equatable.dart';

class HydrationEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime recordedDate;
  final int glassesCount;

  const HydrationEntity({
    required this.id,
    required this.userId,
    required this.recordedDate,
    required this.glassesCount,
  });

  @override
  List<Object?> get props => [id, userId, recordedDate, glassesCount];
}
