import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/models/api_models/signup_model.dart';
import 'package:http/http.dart' as http;
import 'package:auto_flow/constants/api_urls.dart';


class SignupService {
  static Future<SignupModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.signup),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      log("Signup Status: ${response.statusCode}");
      log("Signup Body: ${response.body}");

      final Map<String, dynamic> json = jsonDecode(response.body);
      final model = SignupModel.fromJson(json);


      return model;

    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }
}
