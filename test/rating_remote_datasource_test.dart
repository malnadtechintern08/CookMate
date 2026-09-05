import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:cookmate/features/rating/data/datasources/rating_remote_datasource.dart';

void main() {
  group('RatingRemoteDataSource Tests', () {
    test('Successfully submits rating when server returns success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/api/ratings/submit.php')) {
          final payload = json.decode(request.body);
          expect(payload['stars'], 2);
          expect(payload['category'], 'App Performance');
          return http.Response(
            json.encode({
              'status': 'success',
              'message': 'Rating received',
              'data': {'id': 99},
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final dataSource = RatingRemoteDataSourceImpl(client: mockClient);
      final result = await dataSource.submitRating(
        stars: 2,
        category: 'App Performance',
        feedbackText: 'Great app but needs better offline support',
        userName: 'Test User',
      );

      expect(result, isTrue);
    });

    test('Returns false if server returns error and all endpoints fail', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'status': 'error', 'message': 'Internal error'}), 500);
      });

      final dataSource = RatingRemoteDataSourceImpl(client: mockClient);
      final result = await dataSource.submitRating(
        stars: 1,
        category: 'Bug',
        feedbackText: 'Error test',
      );

      expect(result, isFalse);
    });
  });
}
