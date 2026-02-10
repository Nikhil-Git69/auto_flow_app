// import 'dart:async' show TimeoutException;
// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:auto_flow/constants/api_urls.dart';
// class ResendOtpService {
//   static Future<Map<String, dynamic>> resendOtp({
//     required String email,
//     required String type, // signup, forgot, etc.
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(ApiUrl.resendOtp),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode({
//           "email": email,
//           "type": type,
//         }),
//       ).timeout(const Duration(seconds: 6));
//
//       log("Resend OTP Email: $email");
//       log("Status Code: ${response.statusCode}");
//       log("Raw Body: ${response.body}");
//
//       final responseData = jsonDecode(response.body);
//
//       return {
//         "success": responseData["success"] ?? false,
//         "code": responseData["code"] ?? response.statusCode,
//         "message": responseData["message"] ?? "Something went wrong",
//       };
//     } on TimeoutException {
//       return {
//         "success": false,
//         "code": 408,
//         "message": "Request timed out. Please try again.",
//       };
//     } catch (e) {
//       log("Resend OTP Error: $e");
//       return {
//         "success": false,
//         "code": 500,
//         "message":
//         "Failed to connect to the Server.\nPlease try again.",
//       };
//     }
//   }
// }
