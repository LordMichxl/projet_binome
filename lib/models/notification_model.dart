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

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      targetUid: map['targetUid'] ?? '',
      type: notificationTypeFromString(map['type'] ?? 'matchRequest'),
      message: map['message'] ?? '',
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

}