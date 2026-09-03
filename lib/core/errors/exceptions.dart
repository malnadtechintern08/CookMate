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

class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error occurred'});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}
