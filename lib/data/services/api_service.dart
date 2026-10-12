import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import '../../core/errors/app_exceptions.dart';

class ApiService {
  /// Default Wi-Fi IP of host PC running XAMPP
  static const String defaultLanUrl = 'http://192.168.0.111/afro_barber_api/public';

  /// Android emulator tunnels localhost through 10.0.2.2
  static const String defaultEmulatorUrl = 'http://10.0.2.2/afro_barber_api/public';

  /// Localhost (Web / Desktop)
  static const String defaultLocalhostUrl = 'http://127.0.0.1/afro_barber_api/public';

  // Compile-time dart-define
  static const String _envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String? _customBaseUrl;

  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl {
    // 1. Runtime override (saved in settings / local storage)
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    // 2. Compile-time dart-define
    if (_envUrl.isNotEmpty) {
      return _envUrl.endsWith('/') ? _envUrl.substring(0, _envUrl.length - 1) : _envUrl;
    }
    // 3. Web or desktop — localhost
    if (kIsWeb) return defaultLocalhostUrl;
    // 4. Android (defaults to PC Wi-Fi IP so physical phones work immediately)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return defaultLanUrl;
    }
    // 5. Other platforms (iOS simulator, macOS, Windows desktop)
    return defaultLocalhostUrl;
  }

  /// Test connection to server health endpoint
  static Future<Map<String, dynamic>> testConnection([String? targetUrl]) async {
    final base = (targetUrl != null && targetUrl.isNotEmpty)
        ? (targetUrl.endsWith('/') ? targetUrl.substring(0, targetUrl.length - 1) : targetUrl)
        : baseUrl;
    final healthUri = Uri.parse('$base/api/health');

    try {
      final response = await http
          .get(healthUri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'message': "Connected to Afro Men's Beauty Salon Server",
          'details': body,
        };
      } else {
        return {
          'success': false,
          'message': 'Server responded with HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to reach server: ${e.toString().replaceAll('Exception: ', '')}',
        'details': null,
      };
    }
  }

  static Future<Map<String, String>> _headers() async {
    final token = await LocalStorageService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _uri(String endpoint, [Map<String, dynamic>? queryParams]) {
    var cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    var cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    var fullUrl = '$cleanBase$cleanEndpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryStr = queryParams.entries
          .where((e) => e.value != null)
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      if (queryStr.isNotEmpty) {
        fullUrl += (fullUrl.contains('?') ? '&' : '?') + queryStr;
      }
    }
    return Uri.parse(fullUrl);
  }

  static void _logRequest(String method, Uri url, [Map<String, dynamic>? body]) {
    if (kDebugMode) {
      final sanitized = body != null ? Map<String, dynamic>.from(body) : null;
      if (sanitized != null) {
        if (sanitized.containsKey('password')) sanitized['password'] = '******';
        if (sanitized.containsKey('token')) sanitized['token'] = '******';
      }
      debugPrint('➡️ [API REQUEST] $method $url ${sanitized != null ? jsonEncode(sanitized) : ""}');
    }
  }

  static void _logResponse(String method, Uri url, int statusCode, dynamic body) {
    if (kDebugMode) {
      debugPrint('⬅️ [API RESPONSE] $method $url [HTTP $statusCode]');
      if (statusCode >= 400) {
        debugPrint('⚠️ [API ERROR] $body');
      }
    }
  }

  static Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final url = _uri(endpoint, queryParams);
    try {
      _logRequest('GET', url);
      final headers = await _headers();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      _logResponse('GET', url, response.statusCode, response.body);
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      if (kDebugMode) debugPrint('❌ [API NETWORK ERROR] GET $url: $e');
      throw NetworkException("Unable to connect to Afro Men's Beauty Salon server ($url). Please check your connection.");
    }
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _uri(endpoint);
    try {
      _logRequest('POST', url, body);
      final headers = await _headers();
      final response = await http
          .post(url, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 10));
      _logResponse('POST', url, response.statusCode, response.body);
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      if (kDebugMode) debugPrint('❌ [API NETWORK ERROR] POST $url: $e');
      throw NetworkException("Unable to connect to Afro Men's Beauty Salon server ($url). Please check your connection.");
    }
  }

  static Future<dynamic> upload(String endpoint, String filePath, {Map<String, String>? fields}) async {
    final url = _uri(endpoint);
    try {
      if (kDebugMode) {
        debugPrint('➡️ [API REQUEST] MULTIPART POST $url, File: $filePath');
      }
      final request = http.MultipartRequest('POST', url);
      
      final token = await LocalStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      final multipartFile = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(multipartFile);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final responseStream = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(responseStream);
      
      _logResponse('POST_MULTIPART', url, response.statusCode, response.body);
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      if (kDebugMode) debugPrint('❌ [API NETWORK ERROR] MULTIPART POST $url: $e');
      throw NetworkException("Unable to connect to Afro Men's Beauty Salon server ($url). Please check your connection.");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = _uri(endpoint);
    try {
      _logRequest('DELETE', url);
      final headers = await _headers();
      final response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 10));
      _logResponse('DELETE', url, response.statusCode, response.body);
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      if (kDebugMode) debugPrint('❌ [API NETWORK ERROR] DELETE $url: $e');
      throw NetworkException("Unable to connect to Afro Men's Beauty Salon server ($url). Please check your connection.");
    }
  }

  static dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    final errorMessage = body is Map<String, dynamic> && body['error'] != null
        ? body['error'].toString()
        : 'Server returned error status ${response.statusCode}';

    if (response.statusCode == 401) {
      throw AuthException(errorMessage);
    } else if (response.statusCode == 403) {
      throw ForbiddenException(errorMessage);
    } else if (response.statusCode == 409) {
      throw BookingException(errorMessage);
    } else {
      throw ServerException(errorMessage);
    }
  }
}
