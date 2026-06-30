import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'notification_controller.dart';
import '../models/notification_model.dart';

class ChatController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationController _notifController = NotificationController();
  Stream<List<ChatModel>> getMesChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final chats = snap.docs
          .map((d) => ChatModel.fromMap(d.data(), d.id))
          .toList();

      chats.sort((a, b) {
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });

      return chats;
    });
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final messageRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    // 1. Envoi du message avec un Timestamp Firebase
    await messageRef.set({
      'senderId': senderId,
      'text': text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
    });

    // 2. Mise à jour du dernier message avec un Timestamp Firebase
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    // Notifie l'autre participant
    final chatDoc = await _db.collection('chats').doc(chatId).get();
    final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
    final autreUid = participants.firstWhere((id) => id != senderId, orElse: () => '');

    if (autreUid.isNotEmpty) {
      await _notifController.creerNotification(
        targetUid: autreUid,
        type: NotificationType.newMessage,
        message: 'Nouveau message reçu',
      );
    }
  }
}

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController();
});