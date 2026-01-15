import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  /// Upload a report file with optional AI feedback
  Future<UploadModel?> uploadReport({
    required File file,
    bool aiFeedback = false,
  }) async {
    try {
      final uri = Uri.parse(ApiUrl.analysisUpload);

      final request = http.MultipartRequest('POST', uri);

      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: basename(file.path),
        ),
      );

      // Add AI feedback as a form field
      request.fields['aiFeedback'] = aiFeedback.toString(); // "true"/"false"

      // Add Authorization header
      request.headers['Authorization'] = apiKey;

      // Send the request
      final response = await request.send();

      // Convert response stream to string
      final respStr = await response.stream.bytesToString();
      log("Upload API Response: $respStr");
      // Check HTTP status code first
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(respStr);

        final uploadModel = UploadModel.fromJson(jsonMap);

        if (uploadModel.code == 200) {
          return uploadModel;
        } else {
          log('API returned error code: ${uploadModel.code}');
          return uploadModel;
        }
      } else {
        log('HTTP error ${response.statusCode}: $respStr');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      return null;
    }
  }
}
