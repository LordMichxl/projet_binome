import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_controller.dart';
import '../../providers/match_controller.dart';
import '../../utils/constantes.dart';
import 'chat_view.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moi = ref.watch(currentUserProvider);
    if (moi == null) return const SizedBox.shrink();

    final chatController = ref.read(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatController.getMesChats(moi.uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kCouleurPrimaire));
          }

          final chats = snap.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: kCouleurGris.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune conversation',
                    style: TextStyle(color: kCouleurGris, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Confirmez un binôme pour commencer à discuter',
                    style: TextStyle(color: kCouleurGris, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx2, i) => _ChatTile(chat: chats[i], myUid: moi.uid),
          );
        },
      ),
    );
  }
}

class _ChatTile extends ConsumerWidget {
  final ChatModel chat;
  final String myUid;
  const _ChatTile({required this.chat, required this.myUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autreUid = chat.otherUserId(myUid);
    final matchController = ref.read(matchControllerProvider);

    return FutureBuilder<UserModel?>(
      future: matchController.getUserById(autreUid),
      builder: (ctx, snap) {
        final autre = snap.data;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: kCouleurAccent,
            backgroundImage:
                autre?.photoUrl != null ? NetworkImage(autre!.photoUrl!) : null,
            child: autre?.photoUrl == null
                ? Text(
                    autre?.name.isNotEmpty == true
                        ? autre!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: kCouleurPrimaire),
                  )
                : null,
          ),
          title: Text(autre?.name ?? 'Chargement...'),
          subtitle: Text(
            chat.lastMessage.isEmpty ? 'Aucun message' : chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatView(
                chatId: chat.id,
                autreName: autre?.name ?? '',
              ),
            ),
          ),
        );
      },
    );
  }
}