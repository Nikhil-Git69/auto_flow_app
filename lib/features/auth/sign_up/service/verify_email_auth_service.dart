import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for email verification flow:
/// - verifyEmail  →  POST /auth/verify-email
/// - resendOtp    →  POST /auth/resend-otp
class VerifyEmailAuthService {
  static const _storage = FlutterSecureStorage();

  /// Submit the 6-digit OTP.
  /// On success, stores token + userData and returns {success: true, data: loginData}
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    log('VerifyEmailAuthService: verifying OTP for $email');
    try {
      final response = await ApiClient.post(ApiUrl.verifyEmail, {
        'email': email,
        'otp': otp,
      });

      if (response['success'] == true) {
        final rawData = response['data'];
        if (rawData is Map<String, dynamic>) {
          final inner = rawData['data'];
          if (inner is Map<String, dynamic>) {
            // Store credentials just like login
            final token = inner['token'] as String?;
            if (token != null) {
              await _storage.write(key: 'authToken', value: token);
            }
            final user = inner['user'];
            if (user != null) {
              await _storage.write(key: 'userData', value: jsonEncode(user));
              final userId = user['_id'] ?? user['id'];
              if (userId != null) {
                await _storage.write(key: 'userId', value: userId.toString());
              }
            }

            // Try to parse full LoginResponseModel
            try {
              final loginResponse = LoginResponseModel.fromJson(rawData);
              return {'success': true, 'data': loginResponse.data};
            } catch (_) {
              return {'success': true};
            }
          }
        }
        return {'success': true};
      } else {
        final rawData = response['data'];
        String? code;
        if (rawData is Map<String, dynamic>) {
          code = rawData['code'] as String?;
        }
        return {
          'success': false,
          'message': response['message'] ?? 'Verification failed',
          'code': code,
        };
      }
    } catch (e) {
      log('VerifyEmailAuthService: Error verifying email: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Resend the OTP email.
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    log('VerifyEmailAuthService: resending OTP to $email');
    try {
      final response = await ApiClient.post(ApiUrl.resendOtp, {'email': email});

      if (response['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      log('VerifyEmailAuthService: Error resending OTP: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
