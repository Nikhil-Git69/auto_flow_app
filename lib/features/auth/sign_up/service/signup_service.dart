import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String collegeName = "Default College", // Default as per frontend behavior
    String role = "student", // Default role
  }) async {
    log("SignupService: Attempting signup for $email");
    log(
      "SignupService: Payload -> Name: $name, College: $collegeName, Role: $role",
    );

    try {
      final response = await ApiClient.post(ApiUrl.signup, {
        "name": name,
        "email": email,
        "password": password,
        "collegeName": collegeName,
        "role": role,
      });

      log("SignupService: API Response received: $response");

      if (response['success'] == true) {
        try {
          final loginResponse = LoginResponseModel.fromJson(response['data']);

          if (loginResponse.success && loginResponse.data != null) {
            log("SignupService: Signup successful, tokens received.");
            // Store token
            await _storage.write(
              key: 'authToken',
              value: loginResponse.data!.token,
            );

            // Store user data
            await _storage.write(
              key: 'userData',
              value: jsonEncode(loginResponse.data!.user.toJson()),
            );

            return {"success": true, "data": loginResponse.data};
          } else {
            log(
              "SignupService: LoginResponse indicates failure: ${loginResponse.message}",
            );
            return {"success": false, "message": loginResponse.message};
          }
        } catch (e) {
          log("SignupService: Error parsing response: $e");
          return {
            "success": false,
            "message": "Failed to process signup response: $e",
          };
        }
      } else {
        log(
          "SignupService: API returned success=false. Message: ${response['message']}",
        );
        return {
          "success": false,
          "message": response['message'] ?? "Signup failed",
        };
      }
    } catch (e) {
      log("SignupService: Exception during signup: $e");
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}
