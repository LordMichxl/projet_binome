import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { matchRequest, matchAccepted, newMessage }

NotificationType notificationTypeFromString(String value) {
  return NotificationType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => NotificationType.matchRequest,
  );
}

class NotificationModel {
  final String id;
  final String targetUid; 
  final NotificationType type;
  final String message; 
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.targetUid,
    required this.type,
    required this.message,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      targetUid: data['targetUid'] ?? '',
      type: notificationTypeFromString(data['type'] ?? 'matchRequest'),
      message: data['message'] ?? '',
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetUid': targetUid,
      'type': type.name,
      'message': message,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}