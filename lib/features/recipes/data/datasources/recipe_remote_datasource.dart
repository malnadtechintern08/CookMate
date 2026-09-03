import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> fetchRecipes({
    String? categoryId,
    String? search,
    int limit = 500,
  });

  Future<RecipeModel?> fetchRecipeById(String id);

  Future<List<Map<String, dynamic>>> fetchCategories();
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  RecipeRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  static const Duration timeoutDuration = Duration(seconds: 15);

  /// Solves the InfinityFree slowAES.decrypt(c, 2, a, b) anti-bot challenge
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

  /// Sends HTTP GET with browser headers and automatic InfinityFree cookie challenge solving
  Future<http.Response> _sendRequest(Uri uri) async {
    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json, text/html, */*',
    };

    if (_cachedTestCookie != null) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    var response = await client
        .get(uri, headers: headers)
        .timeout(timeoutDuration);

    // If InfinityFree responds with its slowAES challenge page, solve it and retry
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
        response = await client
            .get(uri, headers: headers)
            .timeout(timeoutDuration);
      }
    }

    return response;
  }

  @override
  Future<List<RecipeModel>> fetchRecipes({
    String? categoryId,
    String? search,
    int limit = 500,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category'] = categoryId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }

      final uri = Uri.parse(AppConstants.apiRecipesEndpoint)
          .replace(queryParameters: queryParams);

      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          final List rawList = decoded['data'] as List;
          return rawList
              .map((item) => RecipeModel.fromMap(
                  Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          message: 'Server responded with status ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while reaching server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to fetch recipes from server: $e');
    }
  }

  @override
  Future<RecipeModel?> fetchRecipeById(String id) async {
    try {
      final uri = Uri.parse(AppConstants.apiRecipesEndpoint)
          .replace(queryParameters: {'id': id});

      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['data'] is Map) {
          return RecipeModel.fromMap(
              Map<String, dynamic>.from(decoded['data'] as Map));
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException(
          message: 'Server error ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while reaching server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to fetch recipe $id: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final uri = Uri.parse(AppConstants.apiCategoriesEndpoint);

      final response = await _sendRequest(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          message: 'Server error ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw NetworkException(message: 'No internet connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Connection timed out while reaching server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Failed to fetch categories: $e');
    }
  }
}
