/// Group/Study Group Model for collaborative activities

// Firebase disabled - using SQLite only
// import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String groupName;
  final String description;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? deadline;
  final String status;
  final String? meetingLink;
  final List<String> memberIds;

  GroupModel({
    required this.id,
    required this.groupName,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.deadline,
    this.status = 'active',
    this.meetingLink,
    this.memberIds = const [],
  });

  // Firebase disabled - fromFirestore method commented out
  /*
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      groupName: data['groupName'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'study',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'active',
      meetingLink: data['meetingLink'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }
  */

  // Firebase disabled - toFirestore method commented out
  /*
  Map<String, dynamic> toFirestore() {
    return {
      'groupName': groupName,
      'description': description,
      'category': category,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status,
      'meetingLink': meetingLink,
      'memberIds': memberIds,
    };
  }
  */

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      groupName: map['groupName'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'study',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      status: map['status'] ?? 'active',
      meetingLink: map['meetingLink'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupName': groupName,
      'description': description,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'meetingLink': meetingLink,
      'memberIds': memberIds,
    };
  }
}

class GroupTaskModel {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String? assignedToId;
  final String? assignedToName;
  final String priority;
  final String status;
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy;

  GroupTaskModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    this.assignedToId,
    this.assignedToName,
    this.priority = 'medium',
    this.status = 'todo',
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
  });

  // Firebase disabled - fromFirestore method commented out
  /*
  factory GroupTaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupTaskModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignedToId: data['assignedToId'],
      assignedToName: data['assignedToName'],
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'todo',
      deadline: (data['deadline'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }
  */

  // Firebase disabled - toFirestore method commented out
  /*
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'priority': priority,
      'status': status,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
  */
}

