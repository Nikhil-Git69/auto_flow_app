class AnalysisModel {
    AnalysisModel({
        required this.httpStatus,
        required this.message,
        required this.code,
        required this.data,
        required this.timestamp,
        required this.asyncRequest,
    });

    final String httpStatus;
    final String message;
    final int code;
    final AnalysisData? data;
    final String timestamp;
    final bool asyncRequest;

    factory AnalysisModel.fromJson(Map<String, dynamic> json) {
        return AnalysisModel(
            httpStatus: json["httpStatus"] ?? "",
            message: json["message"] ?? "",
            code: json["code"] ?? 0,
            data: json["data"] == null
                ? null
                : AnalysisData.fromJson(json["data"]),
            timestamp: json["timestamp"] ?? "",
            asyncRequest: json["asyncRequest"] ?? false,
        );
    }
}

class AnalysisData {
    AnalysisData({
        required this.file,
        required this.formatFeedback,
        required this.contentFeedback,
    });
    final FileInfo file;
    final FormatFeedback formatFeedback;
    final List<String> contentFeedback;

    factory AnalysisData.fromJson(Map<String, dynamic> json) {
        return AnalysisData(
            file: FileInfo.fromJson(json["file"]),
            formatFeedback: FormatFeedback.fromJson(json["format_feedback"]),
            contentFeedback: json["content_feedback"] == null
                ? []
                : List<String>.from(json["content_feedback"]),
        );
    }
}
class FileInfo {
    final String name;
    final String type;

    FileInfo({
        required this.name,
        required this.type,
    });

    factory FileInfo.fromJson(Map<String, dynamic> json) {
        return FileInfo(
            name: json["name"] ?? "",
            type: json["type"] ?? "",
        );
    }
}

class FormatFeedback {
    FormatFeedback({
        required this.issues,
        required this.status,
        required this.analysisMessage,
    });

    final List<String> issues;
    final String status;
    final String analysisMessage;

    factory FormatFeedback.fromJson(Map<String, dynamic> json) {
        return FormatFeedback(
            issues: json["issues"] == null
                ? []
                : List<String>.from(json["issues"]),
            status: json["status"] ?? "",
            analysisMessage: json["analysis_message"] ?? "",
        );
    }
}
