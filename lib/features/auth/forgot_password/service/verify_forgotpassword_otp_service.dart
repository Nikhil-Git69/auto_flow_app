// import 'dart:convert';
// import 'package:auto_flow/constants/api_urls.dart';
// import 'package:http/http.dart' as http;

// class VerifyForgotPasswordOtpService {
//   static Future<Map<String, dynamic>> verifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final url = Uri.parse(ApiUrl.verifyForgotPasswordOtp);

//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode({
//           "email": email,
//           "otp": otp,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       return {
//         "success": data["success"] ?? false,
//         "code": data["code"] ?? response.statusCode,
//         "message": data["message"] ?? "Something went wrong",
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "code": 500,
//         "message": "Something went wrong",
//       };
//     }
//   }
// }
