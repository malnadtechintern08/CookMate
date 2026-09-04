import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(int notificationId);
  Future<int> markAllAsRead();
  Future<bool> markAsUnread(int notificationId);
  Future<NotificationModel> getNotificationDetails(int notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  static String? _cachedInfinityFreeCookie;

  Future<String> _getOrInitAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.keyUserAuthToken);

    if (token != null && token.isNotEmpty && !token.startsWith('cm_')) {
      return token;
    }

    await _ensureInfinityFreeCookie();

    try {
      final response = await _sendRequest(
        Uri.parse(AppConstants.apiSessionEndpoint),
        method: 'POST',
        body: jsonEncode({
          'display_name': prefs.getString(AppConstants.keyUserDisplayName) ?? 'CookMate User',
          'device_info': Platform.operatingSystem,
          if (token != null && !token.startsWith('cm_')) 'auth_token': token,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] != null) {
        final serverToken = decoded['data']['auth_token']?.toString();
        if (serverToken != null && serverToken.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserAuthToken, serverToken);
          return serverToken;
        }
      }
    } catch (_) {}

    if (token != null && token.isNotEmpty) {
      return token;
    }

    token = 'cm_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 * (DateTime.now().microsecond / 1000000))).toInt()}';
    await prefs.setString(AppConstants.keyUserAuthToken, token);
    return token;
  }

  Future<void> _ensureInfinityFreeCookie() async {
    if (_cachedCookieValid()) return;
    try {
      final res = await http.get(
        Uri.parse(AppConstants.apiBaseUrl),
        headers: {
          'User-Agent': 'CookMate-App/1.0.0 (Android; Mobile)',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 4));

      final rawCookie = res.headers['set-cookie'];
      if (rawCookie != null && rawCookie.isNotEmpty) {
        _cachedInfinityFreeCookie = rawCookie.split(';').first.trim();
      }
    } catch (_) {}
  }

  bool _cachedCookieValid() => _cachedInfinityFreeCookie != null && _cachedInfinityFreeCookie!.isNotEmpty;

  Future<http.Response> _sendRequest(
    Uri uri, {
    String method = 'GET',
    Map<String, String>? extraHeaders,
    Object? body,
  }) async {
    await _ensureInfinityFreeCookie();

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': 'CookMate-App/1.0.0 (Flutter; Mobile)',
      if (_cachedCookieValid()) 'Cookie': _cachedInfinityFreeCookie!,
      ...?extraHeaders,
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      case 'PUT':
        return await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      case 'DELETE':
        return await http.delete(uri, headers: headers, body: body).timeout(const Duration(seconds: 10));
      case 'GET':
      default:
        return await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    }
  }

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter}) async {
    final token = await _getOrInitAuthToken();

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (filter != null && filter.isNotEmpty) 'filter': filter,
    };

    final uri = Uri.parse(AppConstants.apiNotificationsEndpoint).replace(queryParameters: queryParams);

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        final List list = decoded['data'] ?? [];
        return list.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    }

    throw Exception('Failed to load notifications: HTTP ${response.statusCode}');
  }

  @override
  Future<int> getUnreadCount() async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsUnreadCountEndpoint);

    try {
      final response = await _sendRequest(
        uri,
        extraHeaders: {
          'Authorization': 'Bearer $token',
          'X-Cookmate-Token': token,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return (decoded['unread_count'] as num?)?.toInt() ?? 0;
        }
      }
    } catch (_) {}

    return 0;
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkReadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      body: jsonEncode({'notification_id': notificationId}),
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> && decoded['success'] == true;
    }

    return false;
  }

  @override
  Future<int> markAllAsRead() async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkAllReadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return (decoded['updated_count'] as num?)?.toInt() ?? 0;
      }
    }

    return 0;
  }

  @override
  Future<bool> markAsUnread(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkUnreadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      body: jsonEncode({'notification_id': notificationId}),
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> && decoded['success'] == true;
    }

    return false;
  }

  @override
  Future<NotificationModel> getNotificationDetails(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsDetailsEndpoint).replace(queryParameters: {
      'id': notificationId.toString(),
    });

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] != null) {
        return NotificationModel.fromJson(decoded['data'] as Map<String, dynamic>);
      }
    }

    throw Exception('Failed to load notification details: HTTP ${response.statusCode}');
  }
}
