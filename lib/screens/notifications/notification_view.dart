import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_controller.dart';
import '../../utils/constantes.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moi = ref.watch(currentUserProvider);
    if (moi == null) return const SizedBox.shrink();

    final controller = ref.read(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => controller.marquerToutesCommeLues(moi.uid),
            child: const Text('Tout marquer lu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: controller.getMesNotifications(moi.uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kCouleurPrimaire));
          }

          final notifs = snap.data ?? [];

          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: kCouleurGris.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text('Aucune notification',
                      style: TextStyle(color: kCouleurGris)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (ctx2, i) {
              final n = notifs[i];
              return ListTile(
                leading: Icon(
                  _iconePour(n.type),
                  color: n.read ? kCouleurGris : kCouleurPrimaire,
                ),
                title: Text(
                  n.message,
                  style: TextStyle(
                    fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(_formatDate(n.createdAt)),
                tileColor: n.read ? null : kCouleurAccent.withOpacity(0.15),
                onTap: () => controller.marquerCommeLue(n.id),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconePour(NotificationType type) {
    switch (type) {
      case NotificationType.matchRequest:
        return Icons.person_add;
      case NotificationType.matchAccepted:
        return Icons.handshake;
      case NotificationType.newMessage:
        return Icons.chat_bubble;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}