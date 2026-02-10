class UserModel {
  final String? id; // _id from backend
  final String email;
  final String name;
  final String collegeName;
  final String? role;
  final String? studentId;
  final String? department;
  final String? logoUrl;
  final bool? isActive;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? preferences;

  UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.collegeName,
    this.role,
    this.studentId,
    this.department,
    this.logoUrl,
    this.isActive,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      collegeName: json['collegeName'] ?? '',
      role: json['role'],
      studentId: json['studentId'],
      department: json['department'],
      logoUrl: json['logoUrl'],
      isActive: json['isActive'],
      lastLogin: json['lastLogin'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'collegeName': collegeName,
      'role': role,
      'studentId': studentId,
      'department': department,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences,
    };
  }
}
