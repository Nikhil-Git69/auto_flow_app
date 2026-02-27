import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AnalysisService {
  static const _storage = FlutterSecureStorage();

  static Future<List<AnalysisModel>> getAllAnalyses({int? limit}) async {
    try {
      final token = await _storage.read(key: 'authToken');
      final userId = await _storage.read(key: 'userId');

      if (token == null) {
        log("AnalysisService: No auth token found");
        return [];
      }

      // Build Query Parameters
      String queryString = "?userId=$userId";
      if (limit != null) {
        queryString += "&limit=$limit";
      }
      // Default to page 1 if not specified
      queryString += "&page=1";

      final uri = Uri.parse("${ApiUrl.baseUrl}/analysis$queryString");

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);

        final List<dynamic> data;
        if (jsonMap['data'] != null) {
          data = jsonMap['data'];
        } else {
          data = [];
        }

        List<AnalysisModel> analyses = data
            .map((e) => AnalysisModel.fromJson(e))
            .toList();

        return analyses;
      }

      log(
        "AnalysisService: Failed to fetch analysis. Status: ${response.statusCode}",
      );
      return [];
    } catch (e) {
      log("AnalysisService: Error fetching analysis: $e");
      rethrow;
    }
  }

  static Future<AnalysisModel?> getAnalysisById(String id) async {
    try {
      final token = await _storage.read(key: 'authToken');
      if (token == null) throw Exception("User not authenticated");

      final uri = Uri.parse("${ApiUrl.baseUrl}/analysis/id/$id");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        if (jsonMap['success'] == true && jsonMap['data'] != null) {
          return AnalysisModel.fromJson(jsonMap['data']);
        }
      }
      return null;
    } catch (e) {
      log("AnalysisService: Error fetching analysis by id: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteAnalysis(String id) async {
    try {
      final token = await _storage.read(key: 'authToken');
      if (token == null) throw Exception("User not authenticated");

      final uri = Uri.parse("${ApiUrl.baseUrl}/analysis/$id");
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Analysis deleted successfully'};
      } else {
        final jsonMap = jsonDecode(response.body);
        return {
          'success': false,
          'message': jsonMap['error'] ?? 'Failed to delete analysis',
        };
      }
    } catch (e) {
      log("AnalysisService: Error deleting analysis: $e");
      return {'success': false, 'message': 'Error deleting analysis'};
    }
  }

  static Future<String?> downloadDocument(
    String analysisId,
    String fileName, {
    bool isPreview = false,
  }) async {
    try {
      final token = await _storage.read(key: 'authToken');
      if (token == null) throw Exception("User not authenticated");

      final uri = Uri.parse("${ApiUrl.baseUrl}/analysis/$analysisId/download");
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Directory directory;
        if (isPreview) {
          directory = await getTemporaryDirectory();
        } else {
          if (Platform.isAndroid) {
            // Request permissions
            if (await Permission.storage.isDenied) {
              await Permission.storage.request();
            }

            // Check if permission is completely denied
            if (await Permission.storage.isPermanentlyDenied) {
              // Fallback direct to external storage instead of failing
            }
            directory = Directory('/storage/emulated/0/Download');
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
        }

        String finalName = fileName;
        if (!finalName.contains('.')) {
          final contentDisposition = response.headers['content-disposition'];
          if (contentDisposition != null) {
            final match = RegExp(
              r'filename="?([^"]+)"?',
            ).firstMatch(contentDisposition);
            if (match != null && match.groupCount >= 1) {
              finalName = match.group(1)!;
            }
          }
          // Fallback if still no extension
          if (!finalName.contains('.')) {
            final contentType = response.headers['content-type'];
            if (contentType?.contains('pdf') == true) {
              finalName += '.pdf';
            } else if (contentType?.contains('word') == true ||
                contentType?.contains('officedocument') == true) {
              finalName += '.docx';
            } else {
              finalName += '.pdf';
            }
          }
        }

        final safeName = finalName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        File file;

        try {
          file = File('${directory.path}/$safeName');
          await file.writeAsBytes(response.bodyBytes);
        } catch (e) {
          // If public Downloads folder is denied (common on Android without specific permissions),
          // fallback to the app-specific external storage directory.
          if (!isPreview && Platform.isAndroid) {
            final fallbackDir = await getExternalStorageDirectory();
            if (fallbackDir != null) {
              file = File('${fallbackDir.path}/$safeName');
              await file.writeAsBytes(response.bodyBytes);
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }

        return file.path;
      }
      log(
        "AnalysisService: Failed to download document. Status: ${response.statusCode}",
      );
      return null;
    } catch (e) {
      log("AnalysisService: Error downloading document: $e");
      return null;
    }
  }
}
