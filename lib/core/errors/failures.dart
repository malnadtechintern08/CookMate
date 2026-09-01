// Domain layer core exceptions and failure models

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested resource was not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid data provided']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error']);
}
