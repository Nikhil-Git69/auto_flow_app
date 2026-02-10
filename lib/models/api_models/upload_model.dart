class AnalysisModel {
  final String? analysisId;
  final String fileName;
  final String? fileType;
  final String? uploadDate;
  final int totalScore;
  final List<AnalysisIssue> issues;
  final String summary;
  final String? formatType;
  final String? processedContent;
  final String? correctedContent;
  final String? correctedPdfBase64;
  final String? status;
  final String? userId;

  AnalysisModel({
    this.analysisId,
    required this.fileName,
    this.fileType,
    this.uploadDate,
    required this.totalScore,
    required this.issues,
    required this.summary,
    this.formatType,
    this.processedContent,
    this.correctedContent,
    this.correctedPdfBase64,
    this.status,
    this.userId,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      analysisId: json['analysisId'] ?? json['_id'],
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'],
      uploadDate: json['uploadDate'] ?? json['analyzedAt'],
      totalScore: json['totalScore'] ?? 0,
      issues:
          (json['issues'] as List?)
              ?.map((e) => AnalysisIssue.fromJson(e))
              .toList() ??
          [],
      summary: json['summary'] ?? '',
      formatType: json['formatType'],
      processedContent: json['processedContent'],
      correctedContent: json['correctedContent'],
      correctedPdfBase64: json['correctedPdfBase64'],
      status: json['status'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'fileName': fileName,
      'fileType': fileType,
      'uploadDate': uploadDate,
      'totalScore': totalScore,
      'issues': issues.map((e) => e.toJson()).toList(),
      'summary': summary,
      'formatType': formatType,
      'processedContent': processedContent,
      'correctedContent': correctedContent,
      'correctedPdfBase64': correctedPdfBase64,
      'status': status,
      'userId': userId,
    };
  }
}

class AnalysisIssue {
  final String? id;
  final String type;
  final String severity;
  final String description;
  final String? suggestion;
  final String? originalText;
  final String? correctedText;
  final IssuePosition? position;
  final bool isFixed;
  final bool customFormatIssue;

  AnalysisIssue({
    this.id,
    required this.type,
    required this.severity,
    required this.description,
    this.suggestion,
    this.originalText,
    this.correctedText,
    this.position,
    this.isFixed = false,
    this.customFormatIssue = false,
  });

  factory AnalysisIssue.fromJson(Map<String, dynamic> json) {
    return AnalysisIssue(
      id: json['id'],
      type: json['type'] ?? 'Unknown',
      severity: json['severity'] ?? 'Minor',
      description: json['description'] ?? '',
      suggestion: json['suggestion'],
      originalText: json['originalText'],
      correctedText: json['correctedText'],
      position: json['position'] != null
          ? IssuePosition.fromJson(json['position'])
          : null,
      isFixed: json['isFixed'] ?? false,
      customFormatIssue: json['customFormatIssue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'description': description,
      'suggestion': suggestion,
      'originalText': originalText,
      'correctedText': correctedText,
      'position': position?.toJson(),
      'isFixed': isFixed,
      'customFormatIssue': customFormatIssue,
    };
  }
}

class IssuePosition {
  final double top;
  final double left;
  final double width;
  final double height;

  IssuePosition({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  factory IssuePosition.fromJson(Map<String, dynamic> json) {
    return IssuePosition(
      top: (json['top'] as num).toDouble(),
      left: (json['left'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'top': top, 'left': left, 'width': width, 'height': height};
  }
}
