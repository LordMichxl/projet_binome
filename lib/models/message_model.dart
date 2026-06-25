import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}