import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recipe_submission_model.dart';

abstract class SubmissionRemoteDataSource {
  Future<String> getOrInitAuthToken();
  Future<Map<String, dynamic>> submitRecipe({
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  });
  Future<List<RecipeSubmissionModel>> getMySubmissions();
  Future<RecipeSubmissionModel> getSubmissionDetails(int id);
  Future<Map<String, dynamic>> updateSubmission({
    required int id,
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  });
  Future<bool> withdrawSubmission(int id);
}

class SubmissionRemoteDataSourceImpl implements SubmissionRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  SubmissionRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  static const Duration timeoutDuration = Duration(seconds: 20);

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

  @override
  Future<String> getOrInitAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.keyUserAuthToken);

    if (token != null && token.isNotEmpty) {
      return token;
    }

    // Initialize session with backend
    try {
      final response = await _sendRequest(
        Uri.parse(AppConstants.apiSessionEndpoint),
        method: 'POST',
        body: jsonEncode({
          'display_name': prefs.getString(AppConstants.keyUserDisplayName) ?? 'CookMate Chef',
          'device_info': Platform.operatingSystem,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        token = decoded['data']['auth_token']?.toString();
        if (token != null && token.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserAuthToken, token);
          return token;
        }
      }
    } catch (_) {}

    // Fallback: Generate local token
    token = 'cm_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 * (DateTime.now().microsecond / 1000000))).toInt()}';
    await prefs.setString(AppConstants.keyUserAuthToken, token);
    return token;
  }

  Future<http.Response> _sendRequest(
    Uri uri, {
    String method = 'GET',
    Map<String, String>? extraHeaders,
    String? body,
  }) async {
    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json, text/html, */*',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    if (_cachedTestCookie != null) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    http.Response response;
    if (method == 'POST') {
      response = await client.post(uri, headers: headers, body: body).timeout(timeoutDuration);
    } else {
      response = await client.get(uri, headers: headers).timeout(timeoutDuration);
    }

    // Handle InfinityFree slowAES challenge
    if (response.body.contains('slowAES.decrypt') ||
        (response.body.contains('<script>') && response.body.contains('__test'))) {
      final keyMatch = RegExp(r'toNumbers\("([a-f0-9]+)"\)').allMatches(response.body).toList();
      if (keyMatch.length >= 3) {
        final a = keyMatch[0].group(1)!;
        final b = keyMatch[1].group(1)!;
        final c = keyMatch[2].group(1)!;
        _cachedTestCookie = _solveChallenge(a, b, c);

        headers['Cookie'] = '__test=$_cachedTestCookie';
        if (method == 'POST') {
          return await client.post(uri, headers: headers, body: body).timeout(timeoutDuration);
        } else {
          return await client.get(uri, headers: headers).timeout(timeoutDuration);
        }
      }
    }

    return response;
  }

  @override
  Future<Map<String, dynamic>> submitRecipe({
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  }) async {
    final token = await getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiSubmissionsCreateEndpoint);

    final request = http.MultipartRequest('POST', uri);
    request.headers['User-Agent'] = mobileUserAgent;
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['X-Cookmate-Token'] = token;

    if (_cachedTestCookie != null) {
      request.headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    // Form fields
    request.fields['recipe_name'] = recipeName;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId;
    request.fields['preparation_time'] = prepTime.toString();
    request.fields['cooking_time'] = cookTime.toString();
    request.fields['servings'] = servings.toString();
    request.fields['difficulty'] = difficulty;
    request.fields['cuisine'] = cuisine;
    request.fields['food_type'] = foodType;
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }
    request.fields['allow_publication'] = allowPublication ? '1' : '0';
    request.fields['show_author_name'] = showAuthorName ? '1' : '0';
    if (authorDisplayName != null && authorDisplayName.isNotEmpty) {
      request.fields['author_display_name'] = authorDisplayName;
    }

    request.fields['ingredients'] = jsonEncode(ingredients);
    request.fields['steps'] = jsonEncode(steps);
    request.fields['tags'] = jsonEncode(tags);

    // Attach image if valid file
    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
    }

    final streamed = await client.send(request).timeout(timeoutDuration);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      try {
        final err = jsonDecode(response.body);
        throw ServerException(message: err['message']?.toString() ?? 'Failed to submit recipe.');
      } catch (e) {
        if (e is ServerException) rethrow;
        throw ServerException(message: 'Server error (${response.statusCode})');
      }
    }
  }

  @override
  Future<List<RecipeSubmissionModel>> getMySubmissions() async {
    final token = await getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiSubmissionsMyEndpoint);

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => RecipeSubmissionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw ServerException(message: 'Failed to load your submissions (${response.statusCode})');
    }
  }

  @override
  Future<RecipeSubmissionModel> getSubmissionDetails(int id) async {
    final token = await getOrInitAuthToken();
    final uri = Uri.parse('${AppConstants.apiSubmissionsDetailsEndpoint}?id=$id');

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return RecipeSubmissionModel.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Invalid submission details response.');
    } else {
      throw ServerException(message: 'Failed to load submission details (${response.statusCode})');
    }
  }

  @override
  Future<Map<String, dynamic>> updateSubmission({
    required int id,
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  }) async {
    final token = await getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiSubmissionsUpdateEndpoint);

    final request = http.MultipartRequest('POST', uri);
    request.headers['User-Agent'] = mobileUserAgent;
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['X-Cookmate-Token'] = token;

    if (_cachedTestCookie != null) {
      request.headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    request.fields['id'] = id.toString();
    request.fields['recipe_name'] = recipeName;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId;
    request.fields['preparation_time'] = prepTime.toString();
    request.fields['cooking_time'] = cookTime.toString();
    request.fields['servings'] = servings.toString();
    request.fields['difficulty'] = difficulty;
    request.fields['cuisine'] = cuisine;
    request.fields['food_type'] = foodType;
    if (notes != null) request.fields['notes'] = notes;
    request.fields['allow_publication'] = allowPublication ? '1' : '0';
    request.fields['show_author_name'] = showAuthorName ? '1' : '0';
    if (authorDisplayName != null) request.fields['author_display_name'] = authorDisplayName;
    request.fields['ingredients'] = jsonEncode(ingredients);
    request.fields['steps'] = jsonEncode(steps);
    request.fields['tags'] = jsonEncode(tags);

    if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
    }

    final streamed = await client.send(request).timeout(timeoutDuration);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerException(message: 'Failed to update submission (${response.statusCode})');
    }
  }

  @override
  Future<bool> withdrawSubmission(int id) async {
    final token = await getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiSubmissionsWithdrawEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['success'] == true;
    }
    return false;
  }
}
