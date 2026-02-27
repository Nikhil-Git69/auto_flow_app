class AdminUploadModel {
  final String id;
  final String fileName;
  final int fileSize;
  final String fileType;
  final DateTime uploadDate;
  final String uploaderName;

  AdminUploadModel({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.uploadDate,
    required this.uploaderName,
  });

  factory AdminUploadModel.fromJson(Map<String, dynamic> json) {
    return AdminUploadModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? 'Unknown File',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      fileType: json['fileType']?.toString() ?? 'unknown',
      uploadDate: json['uploadDate'] != null
          ? (DateTime.tryParse(json['uploadDate'].toString()) ?? DateTime.now())
          : DateTime.now(),
      uploaderName: json['uploaderName']?.toString() ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadDate': uploadDate.toIso8601String(),
      'uploaderName': uploaderName,
    };
  }
}
