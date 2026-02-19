import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // POST Request
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      log("POST Request: $url");
      log("Body: ${jsonEncode(body)}");

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      log("API Error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // GET Request
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final headers = await _getHeaders();
      log("GET Request: $url");

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      log("API Error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      log("PUT Request: $url");
      log("Body: ${jsonEncode(body)}");

      final response = await http
          .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      log("API Error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // PATCH Request
  static Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      log("PATCH Request: $url");
      log("Body: ${jsonEncode(body)}");

      final response = await http
          .patch(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      log("API Error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final headers = await _getHeaders();
      log("DELETE Request: $url");

      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      log("API Error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    log("Response Code: ${response.statusCode}");
    log("Response Body: ${response.body}");

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse server response'};
    }
  }
}
