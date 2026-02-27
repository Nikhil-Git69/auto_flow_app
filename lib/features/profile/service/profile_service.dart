import 'dart:convert';
import 'dart:io';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/core/api/api_client.dart';
import 'package:auto_flow/models/api_models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProfileService {
  static const _storage = FlutterSecureStorage();

  // ─── Get Profile ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await ApiClient.get(ApiUrl.userProfile(userId));
    if (response['success'] == true) {
      try {
        final user = UserModel.fromJson(response['data']['data']);
        return {'success': true, 'data': user};
      } catch (e) {
        return {'success': false, 'message': 'Failed to parse profile'};
      }
    }
    return {
      'success': false,
      'message': response['message'] ?? 'Failed to load profile',
    };
  }

  // ─── Update Profile (name / collegeName) ────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile(
    String userId, {
    String? name,
    String? collegeName,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (collegeName != null) 'collegeName': collegeName,
    };
    final response = await ApiClient.patch(ApiUrl.updateProfile(userId), body);
    if (response['success'] == true) {
      try {
        final user = UserModel.fromJson(response['data']['data']);
        return {'success': true, 'data': user};
      } catch (e) {
        return {'success': false, 'message': 'Failed to parse updated profile'};
      }
    }
    return {
      'success': false,
      'message': response['message'] ?? 'Failed to update profile',
    };
  }

  // ─── Upload Avatar ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> uploadAvatar(
    String userId,
    File imageFile,
  ) async {
    try {
      final token = await _storage.read(key: 'authToken');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrl.uploadAvatar(userId)),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Tell the backend explicitly that it is an image so multer accepts it
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: mimeType,
        ),
      );
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return {'success': true, 'logoUrl': data['data']?['logoUrl']};
      } else {
        return {
          'success': false,
          'message':
              data['error'] ?? data['message'] ?? 'Failed to upload avatar',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  // ─── Change Password ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiClient.post(ApiUrl.changePassword(userId), {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (response['success'] == true) {
      return {'success': true, 'message': 'Password changed successfully'};
    }
    return {
      'success': false,
      'message': response['message'] ?? 'Failed to change password',
    };
  }

  // ─── Save User Locally ───────────────────────────────────────────────────────
  static Future<void> saveUserLocally(UserModel user) async {
    await _storage.write(key: 'userData', value: jsonEncode(user.toJson()));
  }

  // ─── Delete Account ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteAccount(String userId) async {
    final response = await ApiClient.delete(ApiUrl.deleteUser(userId));
    if (response['success'] == true) {
      return {'success': true};
    }
    return {
      'success': false,
      'message': response['message'] ?? 'Failed to delete account',
    };
  }

  // ─── Upload Banner ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> uploadBanner(
    String userId,
    File imageFile,
  ) async {
    try {
      final token = await _storage.read(key: 'authToken');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrl.uploadBanner(userId)),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'banner',
          imageFile.path,
          contentType: mimeType,
        ),
      );
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return {'success': true, 'bannerUrl': data['data']?['bannerUrl']};
      } else {
        return {
          'success': false,
          'message':
              data['error'] ?? data['message'] ?? 'Failed to upload banner',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No Internet Connection'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }
}
