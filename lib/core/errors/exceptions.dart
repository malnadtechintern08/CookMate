// Data layer custom exceptions

class AppDatabaseException implements Exception {
  final String message;
  const AppDatabaseException([this.message = 'Database error occurred']);

  @override
  String toString() => 'AppDatabaseException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Item not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
