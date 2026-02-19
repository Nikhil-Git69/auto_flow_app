class AnalysisModel {
  final String? analysisId;
  final String fileName;
  final String? fileType;
  final String? uploadDate;
  final int totalScore;
  final List<AnalysisIssue> issues;
  final String summary;
  final String? formatType; // 'default', 'custom', 'concept'
  final String? analysisType;
  final String? processedContent; // HTML content for WBS
  final String? correctedContent;
  final String? correctedPdfBase64;
  final String? status;
  final String? userId;
  final String? formatRequirements; // For Custom Analysis
  final Map<String, dynamic>? metadata;
  final List<CommentModel>? comments;

  AnalysisModel({
    this.analysisId,
    required this.fileName,
    this.fileType,
    this.uploadDate,
    required this.totalScore,
    required this.issues,
    required this.summary,
    this.formatType,
    this.analysisType,
    this.processedContent,
    this.correctedContent,
    this.correctedPdfBase64,
    this.status,
    this.userId,
    this.formatRequirements,
    this.metadata,
    this.comments,
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
      analysisType: json['analysisType'],
      processedContent: json['processedContent'],
      correctedContent: json['correctedContent'],
      correctedPdfBase64: json['correctedPdfBase64'],
      status: json['status'],
      userId: json['userId'],
      formatRequirements: json['formatRequirements'],
      metadata: json['metadata'],
      comments: (json['comments'] as List?)
          ?.map((e) => CommentModel.fromJson(e))
          .toList(),
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
      'analysisType': analysisType,
      'processedContent': processedContent,
      'correctedContent': correctedContent,
      'correctedPdfBase64': correctedPdfBase64,
      'status': status,
      'userId': userId,
      'formatRequirements': formatRequirements,
      'metadata': metadata,
      'comments': comments
          ?.map((e) => e.toJson())
          .toList(), // Add comments to toJson
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

class CommentModel {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      role: json['role'] ?? 'Member',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'userName': userName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
