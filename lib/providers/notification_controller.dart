import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> creerNotification({
    required String targetUid,
    required NotificationType type,
    required String message,
  }) async {
    await _db.collection('notifications').add({
      'targetUid': targetUid,
      'type': type.name,
      'message': message,
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<NotificationModel>> getMesNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final notifs = snap.docs
          .map((d) => NotificationModel.fromMap(d.data(), d.id))
          .toList();
      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifs;
    });
  }

  Stream<int> getCompteurNonLues(String uid) {
    return _db
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> marquerCommeLue(String notifId) async {
    await _db.collection('notifications').doc(notifId).update({'read': true});
  }

  Future<void> marquerToutesCommeLues(String uid) async {
    final snap = await _db
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController();
});