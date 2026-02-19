class CommentModel {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String role; // 'Admin' or 'Member'
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.role,
    required this.createdAt,
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
    };
  }
}
