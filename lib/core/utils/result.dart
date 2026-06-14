// lib/core/utils/result.dart

import 'package:equatable/equatable.dart';

sealed class Result<T> extends Equatable {
  const Result();

  @override
  List<Object?> get props => [];

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? getOrNull() {
    return switch (this) {
      Success<T> s => s.data,
      Failure<T> _ => null,
    };
  }

  R when<R>(
      {required R Function(Success<T>) success,
      required R Function(Failure<T>) failure}) {
    return switch (this) {
      Success<T> s => success(s),
      Failure<T> f => failure(f),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final Exception exception;
  final String userMessage;

  const Failure(this.exception, this.userMessage);

  @override
  List<Object?> get props => [exception, userMessage];
}
