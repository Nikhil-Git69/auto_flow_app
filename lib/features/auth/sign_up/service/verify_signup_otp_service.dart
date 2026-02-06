import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auto_flow/constants/api_urls.dart';

class VerifySignupOtpService {
  static final _storage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.verifySingup),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      ).timeout(const Duration(seconds: 6));

      log("Verify OTP Email: $email");
      log("Verify OTP: $otp");
      log("Status Code: ${response.statusCode}");
      log("Raw Data: ${response.body}");

      final responseData = jsonDecode(response.body);

      log("Response Code: ${responseData["code"]}");
      log("Response Message: ${responseData["message"]}");

      if (response.statusCode == 200 &&
          responseData['code'] == 200) {

        final accessToken =
        responseData['data']?['accessToken'];

        if (accessToken != null) {
          await _storage.write(
              key: 'accessToken',
              value: accessToken);
        }

        return {
          "success": true,
          "data": responseData['data'],
        };
      }

      return {
        "success": false,
        "message": responseData['message'] ??
            "OTP verification failed.",
      };

    } on TimeoutException {
      return {
        "success": false,
        "timeout": true,
        "message": "Request timed out. Please try again.",
      };
    } catch (e) {
      return {
        "success": false,
        "message":
        "Failed to connect to the Server. \n Please Try Again.",
      };
    }
  }
}
