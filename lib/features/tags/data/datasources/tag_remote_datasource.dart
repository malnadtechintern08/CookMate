import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../recipes/data/models/recipe_model.dart';
import '../models/tag_model.dart';

abstract class TagRemoteDataSource {
  Future<List<TagModel>> fetchPopularTags({int limit = 15});
  Future<List<TagModel>> searchTags(String query, {int limit = 10});
  Future<Map<String, dynamic>> fetchRecipesByTag({
    required String tag,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> searchRecipesUnified({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  TagRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  static const Duration timeoutDuration = Duration(seconds: 15);

  String _solveChallenge(String keyHex, String ivHex, String ctHex) {
    final key = Uint8List.fromList(hex.decode(keyHex));
    final iv = Uint8List.fromList(hex.decode(ivHex));
    final ct = Uint8List.fromList(hex.decode(ctHex));

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));

    final out = Uint8List(16);
    cipher.processBlock(ct, 0, out, 0);
    return hex.encode(out);
  }

  Future<http.Response> _sendRequest(Uri uri) async {
    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json, text/html, */*',
    };

    if (_cachedTestCookie != null) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    var response = await client.get(uri, headers: headers).timeout(timeoutDuration);

    if (response.body.contains('slowAES.decrypt') &&
        response.body.contains('toNumbers(')) {
      final reg = RegExp(r'toNumbers\("([a-f0-9]+)"\)');
      final matches = reg.allMatches(response.body).toList();
      if (matches.length >= 3) {
        final a = matches[0].group(1)!;
        final b = matches[1].group(1)!;
        final c = matches[2].group(1)!;
        _cachedTestCookie = _solveChallenge(a, b, c);

        headers['Cookie'] = '__test=$_cachedTestCookie';
        response = await client.get(uri, headers: headers).timeout(timeoutDuration);
      }
    }

    return response;
  }

  @override
  Future<List<TagModel>> fetchPopularTags({int limit = 15}) async {
    try {
      final uri = Uri.parse(AppConstants.apiTagsPopularEndpoint)
          .replace(queryParameters: {'limit': limit.toString()});
      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => TagModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
      return [];
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while fetching tags');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to fetch popular tags: $e');
    }
  }

  @override
  Future<List<TagModel>> searchTags(String query, {int limit = 10}) async {
    try {
      final uri = Uri.parse(AppConstants.apiTagsSearchEndpoint)
          .replace(queryParameters: {'q': query, 'limit': limit.toString()});
      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => TagModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
      return [];
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while searching tags');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to search tags: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchRecipesByTag({
    required String tag,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.apiTagsRecipesEndpoint).replace(
        queryParameters: {
          'tag': tag,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final rawList = (decoded['data'] as List?) ?? [];
          final recipes = rawList
              .map((item) => RecipeModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();

          return {
            'total': (decoded['total'] as num?)?.toInt() ?? recipes.length,
            'page': (decoded['page'] as num?)?.toInt() ?? page,
            'limit': (decoded['limit'] as num?)?.toInt() ?? limit,
            'totalPages': (decoded['totalPages'] as num?)?.toInt() ?? 1,
            'tag': decoded['tag']?.toString() ?? tag,
            'recipes': recipes,
          };
        }
      }
      return {'total': 0, 'page': page, 'limit': limit, 'totalPages': 0, 'tag': tag, 'recipes': <RecipeModel>[]};
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while loading hashtag recipes');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to fetch hashtag recipes: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> searchRecipesUnified({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.apiSearchEndpoint).replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          final rawList = (decoded['data'] as List?) ?? [];
          final recipes = rawList
              .map((item) => RecipeModel.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();

          return {
            'total': (decoded['total'] as num?)?.toInt() ?? recipes.length,
            'page': (decoded['page'] as num?)?.toInt() ?? page,
            'limit': (decoded['limit'] as num?)?.toInt() ?? limit,
            'totalPages': (decoded['totalPages'] as num?)?.toInt() ?? 1,
            'isHashtagSearch': decoded['is_hashtag_search'] == true,
            'recipes': recipes,
          };
        }
      }
      return {'total': 0, 'page': page, 'limit': limit, 'totalPages': 0, 'isHashtagSearch': false, 'recipes': <RecipeModel>[]};
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while searching recipes');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to search recipes: $e');
    }
  }
}
