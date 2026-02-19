class ActivityModel {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? assigneeId;
  final DateTime? startDate;
  final DateTime? deadline;
  final List<MemberStatus>? memberStatuses;
  final String? linkedAnalysisId;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.startDate,
    this.deadline,
    this.memberStatuses,
    this.linkedAnalysisId,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Task',
      description: json['description'],
      status: json['status'] ?? 'To Do',
      priority: json['priority'] ?? 'Medium',
      assigneeId: json['assigneeId'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null,
      memberStatuses: json['memberStatuses'] != null
          ? (json['memberStatuses'] as List)
                .map((e) => MemberStatus.fromJson(e))
                .toList()
          : [],
      linkedAnalysisId: json['linkedAnalysisId'],
      color: json['color'],
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
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assigneeId': assigneeId,
      'startDate': startDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'memberStatuses': memberStatuses?.map((e) => e.toJson()).toList(),
      'linkedAnalysisId': linkedAnalysisId,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MemberStatus {
  final String userId;
  final String status;
  final DateTime updatedAt;

  MemberStatus({
    required this.userId,
    required this.status,
    required this.updatedAt,
  });

  factory MemberStatus.fromJson(Map<String, dynamic> json) {
    return MemberStatus(
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'To Do',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BoardModel {
  final String id;
  final String name;
  final List<ActivityModel> tasks;

  BoardModel({required this.id, required this.name, required this.tasks});

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Main Board',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
                .map((e) => ActivityModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
