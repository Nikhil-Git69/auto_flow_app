class UserModel {
  final String? id; // _id from backend
  final String email;
  final String name;
  final String collegeName;
  final String? role;
  final String? studentId;
  final String? department;
  final String? logoUrl;
  final String? bannerUrl;
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
    this.bannerUrl,
    this.isActive,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? collegeName,
    String? role,
    String? studentId,
    String? department,
    String? logoUrl,
    String? bannerUrl,
    bool? isActive,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      collegeName: collegeName ?? this.collegeName,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }

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
      bannerUrl: json['bannerUrl'],
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
      'bannerUrl': bannerUrl,
      'isActive': isActive,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences,
    };
  }
}
