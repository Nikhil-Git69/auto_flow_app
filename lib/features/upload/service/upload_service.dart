import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UploadService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> uploadFile({
    required File file,
    String formatType = 'default',
    String? formatRequirements,
    File? templateFile,
  }) async {
    final urlString = "${ApiUrl.baseUrl}/analysis/upload-file";
    log("UploadService: Starting upload to $urlString");

    try {
      final uri = Uri.parse(urlString);
      final request = http.MultipartRequest('POST', uri);

      log("UploadService: File path: ${file.path}");

      // Add File (document)
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
          filename: basename(file.path),
        ),
      );

      // Add Template File if exists
      if (templateFile != null) {
        log("UploadService: Adding template file: ${templateFile.path}");
        request.files.add(
          await http.MultipartFile.fromPath(
            'templateFile',
            templateFile.path,
            filename: basename(templateFile.path),
          ),
        );
      }

      // Get User ID and Token
      String? userId;
      final userDataStr = await _storage.read(key: 'userData');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        userId = userData['_id'] ?? userData['id'];
      }

      final token = await _storage.read(key: 'authToken');

      if (userId == null || token == null) {
        log(
          "UploadService: Missing Auth Data - UserId: $userId, Token: ${token != null ? 'Yes' : 'No'}",
        );
        return {"success": false, "message": "User not authenticated"};
      }

      // Add Fields
      request.fields['userId'] = userId;
      request.fields['fileName'] = basename(file.path);
      request.fields['formatType'] = formatType;

      if (formatRequirements != null && formatRequirements.isNotEmpty) {
        request.fields['formatRequirements'] = formatRequirements;
      } else if (formatType == 'custom') {
        // Default custom requirements if none provided
        request.fields['formatRequirements'] = "Standard formatting.";
      }

      log("UploadService: Fields -> ${request.fields}");

      // Add Headers (Auth)
      request.headers['Authorization'] = 'Bearer $token';

      log("UploadService: Sending request...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log("UploadService: Response Status: ${response.statusCode}");
      log("UploadService: Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonMap = jsonDecode(response.body);
        if (jsonMap['success'] == true && jsonMap['data'] != null) {
          return {
            "success": true,
            "data": AnalysisModel.fromJson(jsonMap['data']),
          };
        } else {
          return {
            "success": false,
            "message":
                jsonMap['error'] ?? jsonMap['message'] ?? "Upload failed",
          };
        }
      } else {
        try {
          final errorMap = jsonDecode(response.body);
          return {
            "success": false,
            "message":
                errorMap['error'] ??
                errorMap['message'] ??
                "Upload failed (${response.statusCode})",
          };
        } catch (_) {
          return {
            "success": false,
            "message": "Upload failed with status ${response.statusCode}",
          };
        }
      }
    } catch (e) {
      log("UploadService: Exception: $e");
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // Helper to generate requirements string from a Map (similar to Dashboard.tsx)
  static String generateRequirementsString(Map<String, dynamic> fields) {
    if (fields.isEmpty) return "";

    final buffer = StringBuffer();
    buffer.writeln("### MANDATORY FORMATTING RULES ###");

    fields.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty && value != 'Default') {
        buffer.writeln(
          "!!! RULE: DOCUMENT MUST USE ${value.toString().toUpperCase()} FOR ${key.toUpperCase()} !!!",
        );
      }
    });

    final result = buffer.toString();
    return result.length <= "### MANDATORY FORMATTING RULES ###\n".length
        ? "Standard formatting."
        : result;
  }
}
