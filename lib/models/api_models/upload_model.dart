
class UploadModel {
    UploadModel({
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
    final UploadResponse? data;
    final String timestamp;
    final bool asyncRequest;

    factory UploadModel.fromJson(Map<String, dynamic> json){ 
        return UploadModel(
            httpStatus: json["httpStatus"] ?? "",
            message: json["message"] ?? "",
            code: json["code"] ?? 0,
            data: json["data"] == null ? null : UploadResponse.fromJson(json["data"]),
            timestamp: json["timestamp"] ?? "",
            asyncRequest: json["asyncRequest"] ?? false,
        );
    }

}

class UploadResponse {
    UploadResponse({
        required this.formatFeedback,
        required this.contentFeedback,
    });

    final List<String> formatFeedback;
    final List<String> contentFeedback;

    factory UploadResponse.fromJson(Map<String, dynamic> json){ 
        return UploadResponse(
            formatFeedback: json["format_feedback"] == null ? [] : List<String>.from(json["format_feedback"]!.map((x) => x)),
            contentFeedback: json["content_feedback"] == null ? [] : List<String>.from(json["content_feedback"]!.map((x) => x)),
        );
    }

}
