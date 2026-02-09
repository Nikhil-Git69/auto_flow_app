class AnalysisModel {
  AnalysisModel({
    required this.httpStatus,
    required this.message,
    required this.code,
    required this.data,
    required this.timestamp,
    required this.asyncRequest,
  });

  final String? httpStatus;
  final String? message;
  final int? code;
  final Data? data;
  final String? timestamp;
  final bool? asyncRequest;

  factory AnalysisModel.fromJson(Map<String, dynamic> json){
    return AnalysisModel(
      httpStatus: json["httpStatus"],
      message: json["message"],
      code: json["code"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
      timestamp: json["timestamp"],
      asyncRequest: json["asyncRequest"],
    );
  }

}

class Data {
  Data({
    required this.file,
    required this.formatFeedback,
    required this.grammarFeedback,
    required this.contentFeedback,
  });

  final FileClass? file;
  final FormatFeedback? formatFeedback;
  final GrammarFeedback? grammarFeedback;
  final ContentFeedback? contentFeedback;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      file: json["file"] == null ? null : FileClass.fromJson(json["file"]),
      formatFeedback: json["format_feedback"] == null ? null : FormatFeedback.fromJson(json["format_feedback"]),
      grammarFeedback: json["grammar_feedback"] == null ? null : GrammarFeedback.fromJson(json["grammar_feedback"]),
      contentFeedback: json["content_feedback"] == null ? null : ContentFeedback.fromJson(json["content_feedback"]),
    );
  }

}

class ContentFeedback {
  ContentFeedback({
    required this.overallQuality,
    required this.summary,
    required this.issues,
  });

  final String? overallQuality;
  final String? summary;
  final ContentFeedbackIssues? issues;

  factory ContentFeedback.fromJson(Map<String, dynamic> json){
    return ContentFeedback(
      overallQuality: json["overall_quality"],
      summary: json["summary"],
      issues: json["issues"] == null ? null : ContentFeedbackIssues.fromJson(json["issues"]),
    );
  }

}

class ContentFeedbackIssues {
  ContentFeedbackIssues({
    required this.clarity,
    required this.concept,
  });

  final List<String> clarity;
  final List<String> concept;

  factory ContentFeedbackIssues.fromJson(Map<String, dynamic> json){
    return ContentFeedbackIssues(
      clarity: json["clarity"] == null ? [] : List<String>.from(json["clarity"]!.map((x) => x)),
      concept: json["concept"] == null ? [] : List<String>.from(json["concept"]!.map((x) => x)),
    );
  }

}

class FileClass {
  FileClass({
    required this.name,
    required this.type,
  });

  final String? name;
  final String? type;

  factory FileClass.fromJson(Map<String, dynamic> json){
    return FileClass(
      name: json["name"],
      type: json["type"],
    );
  }

}

class FormatFeedback {
  FormatFeedback({
    required this.issues,
    required this.status,
    required this.analysisMessage,
  });

  final FormatFeedbackIssues? issues;
  final String? status;
  final String? analysisMessage;

  factory FormatFeedback.fromJson(Map<String, dynamic> json){
    return FormatFeedback(
      issues: json["issues"] == null ? null : FormatFeedbackIssues.fromJson(json["issues"]),
      status: json["status"],
      analysisMessage: json["analysis_message"],
    );
  }

}

class FormatFeedbackIssues {
  FormatFeedbackIssues({
    required this.font,
  });

  final List<String> font;

  factory FormatFeedbackIssues.fromJson(Map<String, dynamic> json){
    return FormatFeedbackIssues(
      font: json["font"] == null ? [] : List<String>.from(json["font"]!.map((x) => x)),
    );
  }

}

class GrammarFeedback {
  GrammarFeedback({
    required this.status,
    required this.summary,
    required this.count,
    required this.issues,
    required this.ignoredBlocks,
  });

  final String? status;
  final String? summary;
  final int? count;
  final List<GrammerIssue> issues;
  final int? ignoredBlocks;

  factory GrammarFeedback.fromJson(Map<String, dynamic> json){
    return GrammarFeedback(
      status: json["status"],
      summary: json["summary"],
      count: json["count"],
      issues: json["issues"] == null ? [] : List<GrammerIssue>.from(json["issues"]!.map((x) => GrammerIssue.fromJson(x))),
      ignoredBlocks: json["ignored_blocks"],
    );
  }

}

class GrammerIssue {
  GrammerIssue({
    required this.type,
    required this.message,
    required this.context,
  });

  final String? type;
  final String? message;
  final String? context;

  factory GrammerIssue.fromJson(Map<String, dynamic> json){
    return GrammerIssue(
      type: json["type"],
      message: json["message"],
      context: json["context"],
    );
  }

}
