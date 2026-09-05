import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/faq_model.dart';
import '../models/support_page_model.dart';

abstract class SupportRemoteDataSource {
  Future<SupportPageModel> getPage(String slug);
  Future<List<FaqModel>> getFaqs({String? category});
  Future<bool> submitContactInquiry({
    required String name,
    required String email,
    required String subject,
    required String message,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const Duration timeoutDuration = Duration(seconds: 12);

  SupportRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

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

  Future<String?> _ensureInfinityFreeCookie() async {
    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      return _cachedTestCookie;
    }

    try {
      final headers = <String, String>{
        'User-Agent': mobileUserAgent,
        'Accept': 'application/json, text/html, */*',
      };

      final probeUri = Uri.parse(AppConstants.apiSupportPageEndpoint);
      final response = await client.get(probeUri, headers: headers).timeout(timeoutDuration);

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
          await client.get(
            Uri.parse('${AppConstants.apiSupportPageEndpoint}?i=1'),
            headers: headers,
          ).timeout(timeoutDuration);
        }
      }
    } catch (_) {}

    return _cachedTestCookie;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }
    return headers;
  }

  @override
  Future<SupportPageModel> getPage(String slug) async {
    try {
      await _ensureInfinityFreeCookie();
      final uri = Uri.parse('${AppConstants.apiSupportPageEndpoint}?slug=$slug');
      final res = await client.get(uri, headers: _buildHeaders()).timeout(timeoutDuration);

      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body);
        if (jsonBody is Map<String, dynamic> && jsonBody['status'] == 'success' && jsonBody['data'] != null) {
          return SupportPageModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Fallback on offline/error
    }

    // Default offline fallback
    switch (slug) {
      case 'privacy-policy':
        return SupportPageModel.defaultPrivacyPolicy();
      case 'contact-us':
        return SupportPageModel.defaultContactUs();
      case 'help-center':
        return SupportPageModel.defaultHelpCenter();
      case 'safety-guidelines':
        return SupportPageModel.defaultSafetyGuidelines();
      default:
        return SupportPageModel(
          id: slug,
          title: slug.replaceAll('-', ' ').toUpperCase(),
          slug: slug,
          summary: 'Information about $slug',
          content: 'No content available.',
        );
    }
  }

  @override
  Future<List<FaqModel>> getFaqs({String? category}) async {
    try {
      await _ensureInfinityFreeCookie();
      final queryParams = category != null && category.isNotEmpty ? '?category=${Uri.encodeComponent(category)}' : '';
      final uri = Uri.parse('${AppConstants.apiFaqsEndpoint}$queryParams');
      final res = await client.get(uri, headers: _buildHeaders()).timeout(timeoutDuration);

      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body);
        if (jsonBody is Map<String, dynamic> && jsonBody['status'] == 'success' && jsonBody['data'] is List) {
          final list = (jsonBody['data'] as List)
              .map((item) => FaqModel.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } catch (_) {
      // Fallback on offline/error
    }

    // Offline fallback
    final all = FaqModel.defaultFaqs();
    if (category != null && category.isNotEmpty && category != 'All') {
      return all.where((f) => f.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return all;
  }

  @override
  Future<bool> submitContactInquiry({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await _ensureInfinityFreeCookie();
      final uri = Uri.parse(AppConstants.apiContactSubmitEndpoint);
      final body = json.encode({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      });

      final res = await client.post(uri, headers: _buildHeaders(), body: body).timeout(timeoutDuration);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonBody = json.decode(res.body);
        return jsonBody['status'] == 'success';
      }
    } catch (_) {}
    return false;
  }
}
