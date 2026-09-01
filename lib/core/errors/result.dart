import 'package:hrm_app/core/errors/failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) => switch (this) {
    FailureResult<T>(:final failure) => onFailure(failure),
    Success<T>(:final value) => onSuccess(value),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
