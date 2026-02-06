import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'package:auto_flow/constants/api_urls.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:auto_flow/models/request_models/guideline_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AnalysisApiService {
  final String apiKey;

  AnalysisApiService({required this.apiKey});

  Future<AnalysisModel?> uploadReport({
    required File file,
    required GuidelinesModel guidelines,
    bool aiFeedback = false,
  }) async {
    try {
      final uri = Uri.parse(ApiUrl.analysisUpload);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: basename(file.path),
        ),
      );

      request.fields['aiFeedback'] = aiFeedback.toString();
      request.fields['guidelines'] = jsonEncode(guidelines.toJson());
      request.headers['Authorization'] = apiKey;

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      log("Upload API Response: $respStr");
      log("Upload API Request: file: $file,guidelines: ${guidelines.toJson()},aiFeedback: $aiFeedback");

      final jsonMap = jsonDecode(respStr);
      final analysisModel = AnalysisModel.fromJson(jsonMap);

      if (response.statusCode != 200) {
        log('HTTP error ${response.statusCode}');
      }

      return analysisModel;
    } catch (e) {
      log('Upload exception: $e');
      return null;
    }
  }
}
