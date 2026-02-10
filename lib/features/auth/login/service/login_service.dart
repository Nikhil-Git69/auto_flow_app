import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/login_response_model.dart';

class LoginService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(ApiUrl.login, {
      "email": email,
      "password": password,
    });

    if (response['success'] == true) {
      try {
        final loginResponse = LoginResponseModel.fromJson(response['data']);
        
        if (loginResponse.success && loginResponse.data != null) {
          //  token
          await _storage.write(key: 'authToken', value: loginResponse.data!.token);
          
          await _storage.write(
            key: 'userData', 
            value: jsonEncode(loginResponse.data!.user.toJson())
          );

          return {
            "success": true,
            "data": loginResponse.data
          };
        } else {
           return {
            "success": false,
            "message": loginResponse.message
          };
        }
      } catch (e) {
        return {
          "success": false,
          "message": "Failed to process login response"
        };
      }
    } else {
      return {
        "success": false,
        "message": response['message'] ?? "Login failed"
      };
    }
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
