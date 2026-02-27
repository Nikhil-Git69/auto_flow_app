import 'dart:convert';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(ApiUrl.resetPassword);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": data["success"] ?? false,
        "message": data["message"] ?? "Something went wrong",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    }
  }
}
