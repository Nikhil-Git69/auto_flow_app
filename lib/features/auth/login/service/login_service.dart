import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auto_flow/constants/api_urls.dart';

class LoginService {
  static final _storage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiUrl.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      )
          .timeout(const Duration(seconds: 6));

      log("Login Request Email: $email");
      log("Status Code: ${response.statusCode}");
      log("Raw Body: '${response.body}'");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final int code = responseData["code"] ?? response.statusCode;
      final String message =
      (responseData["message"] ?? "Something went wrong").toString();

      //  save token
      if (response.statusCode == 200 && code == 200) {
        final token = responseData["data"]?["accessToken"];

        if (token != null && token.toString().isNotEmpty) {
          await _storage.write(key: "accessToken", value: token.toString());
        }

        return {
          "success": true,
          "code": code,
          "message": message,
          "data": responseData["data"],
        };
      }

      if (code == 422) {
        return {
          "success": false,
          "code": code,
          "unverified": true,
          "message": message,
        };
      }

      return {
        "success": false,
        "code": code,
        "message": message,
      };
    } on TimeoutException {
      return {
        "success": false,
        "code": 408,
        "timeout": true,
        "message": "Request timed out. Please try again.",
      };
    } catch (e) {
      log("Login error: $e");
      return {
        "success": false,
        "code": 500,
        "message": "Failed to connect to the Server.\nPlease try again.",
      };
    }
  }
}
