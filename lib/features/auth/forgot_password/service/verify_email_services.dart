// import 'dart:convert';
// import 'package:auto_flow/constants/api_urls.dart';
// import 'package:http/http.dart' as http;

// class VerifyForgetPasswordEmailService {
//   static Future<Map<String, dynamic>> verifyEmail(String email) async {
//     try {
//       final url = Uri.parse(ApiUrl.forgotPassword);

//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//         body: jsonEncode({"email": email}),
//       );

//       final data = jsonDecode(response.body);

//       return {
//         "success": data["success"] ?? false,
//         "code": data["code"] ?? 500,
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
