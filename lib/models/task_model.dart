// Firebase disabled - using SQLite only
// import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assigneeName;
  final String? assigneeId;
  final String priority; // 'urgent', 'medium', 'low'
  final String status; // 'todo', 'in-progress', 'done'
  final DateTime deadline;
  final DateTime createdAt;
  final String createdBy;
  final double? estimatedHours;
  final String? category;
  final List<String> tagIds;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeName,
    this.assigneeId,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.createdBy,
    this.estimatedHours,
    this.category,
    this.tagIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignee_name': assigneeName,
      'assignee_id': assigneeId,
      'priority': priority,
      'status': status,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'estimated_hours': estimatedHours,
      'category': category,
    };
  }
}

class TagModel {
  final String id;
  final String name;
  final String color;

  TagModel({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}

class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CommentModel {
  final String id;
  final String taskId;
  final String commentText;
  final String reportedBy;
  final DateTime reportedAt;
  final String commentType;
  final String? attachmentUrl;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.commentText,
    required this.reportedBy,
    required this.reportedAt,
    this.commentType = 'text',
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'comment_text': commentText,
      'reported_by': reportedBy,
      'reported_at': reportedAt.toIso8601String(),
      'comment_type': commentType,
      'attachment_path': attachmentUrl,
    };
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? taskId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.taskId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'task_id': taskId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

