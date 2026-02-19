import 'dart:convert';
import 'dart:developer';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
}
