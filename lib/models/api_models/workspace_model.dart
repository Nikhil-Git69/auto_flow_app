import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:auto_flow/models/api_models/user_model.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String? description;
  final String accessCode;
  final String ownerId;
  final List<String>? memberIds;
  final List<AnalysisModel>? documents;
  final DateTime createdAt;
  final List<UserModel>? members;

  WorkspaceModel({
    required this.id,
    required this.name,
    this.description,
    required this.accessCode,
    required this.ownerId,
    this.memberIds,
    this.documents,
    required this.createdAt,
    this.members,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Untitled Workspace',
      description: json['description'],
      accessCode: json['accessCode'] ?? '',
      ownerId: json['ownerId'] is String
          ? json['ownerId']
          : (json['ownerId']?['_id'] ?? ''),
      memberIds: (json['members'] as List<dynamic>?)
          ?.map((e) => e is String ? e : (e['_id'] as String? ?? ''))
          .toList(),
      members: (json['members'] as List<dynamic>?)?.map((e) {
        if (e is String) {
          return UserModel(id: e, name: 'Member', email: '', collegeName: '');
        }
        return UserModel.fromJson(e as Map<String, dynamic>);
      }).toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => AnalysisModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'accessCode': accessCode,
      'ownerId': ownerId,
      'members': memberIds,
      'documents': documents?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
