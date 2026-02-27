import 'dart:convert';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:http/http.dart' as http;

class VerifyForgotPasswordOtpService {
  /// Verify the reset OTP → POST /auth/verify-reset-otp
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(ApiUrl.verifyResetOtp);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      return {
        "success": data["success"] ?? false,
        "message": data["message"] ?? "Something went wrong",
        "code": data["code"],
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    }
  }

  /// Resend the reset OTP → POST /auth/resend-otp
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final url = Uri.parse(ApiUrl.resendOtp);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
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
