import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
    };
  }

  // Retrouve l'autre participant que l'utilisateur connecté
  String otherUserId(String currentUid) {
    return participants.firstWhere((id) => id != currentUid, orElse: () => '');
  }
}