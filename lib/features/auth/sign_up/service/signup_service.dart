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
        final rawData = response['data'];
        if (rawData is Map<String, dynamic>) {
          // New flow: backend returns requiresVerification instead of token
          if (rawData['requiresVerification'] == true ||
              rawData['data'] == null) {
            log(
              "SignupService: Verification required for ${rawData['email'] ?? email}",
            );
            return {
              "success": true,
              "requiresVerification": true,
              "email": rawData['email'] ?? email,
            };
          }
          // Legacy path: token returned directly
          try {
            final loginResponse = LoginResponseModel.fromJson(rawData);
            if (loginResponse.success && loginResponse.data != null) {
              log("SignupService: Signup successful, tokens received.");
              await _storage.write(
                key: 'authToken',
                value: loginResponse.data!.token,
              );
              await _storage.write(
                key: 'userData',
                value: jsonEncode(loginResponse.data!.user.toJson()),
              );
              return {"success": true, "data": loginResponse.data};
            } else {
              return {"success": false, "message": loginResponse.message};
            }
          } catch (e) {
            log("SignupService: Error parsing response: $e");
            return {
              "success": false,
              "message": "Failed to process signup response: $e",
            };
          }
        }
        return {"success": false, "message": "Unexpected response format"};
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
