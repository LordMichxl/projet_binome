import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_controller.dart';
import '../../utils/constantes.dart';

class ChatView extends ConsumerStatefulWidget {
  final String chatId;
  final String autreName;

  const ChatView({super.key, required this.chatId, required this.autreName});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _envoyer() {
    final moi = ref.read(currentUserProvider);
    if (moi == null || _textController.text.trim().isEmpty) return;

    ref.read(chatControllerProvider).sendMessage(
          chatId: widget.chatId,
          senderId: moi.uid,
          text: _textController.text,
        );

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final moi = ref.watch(currentUserProvider);
    final chatController = ref.read(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.autreName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatController.getMessages(widget.chatId),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: kCouleurPrimaire));
                }

                final messages = snap.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun message. Dites bonjour !',
                      style: TextStyle(color: kCouleurGris),
                    ),
                  );
                }

                // Scroll automatique vers le bas après le rendu
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(kPadding),
                  itemCount: messages.length,
                  itemBuilder: (ctx2, i) {
                    final msg = messages[i];
                    final estMoi = msg.senderId == moi?.uid;
                    return _Bulle(message: msg, estMoi: estMoi);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(kPaddingSmall),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: kCouleurAccent.withOpacity(0.3),
                      ),
                      onSubmitted: (_) => _envoyer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: kCouleurPrimaire,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _envoyer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bulle extends StatelessWidget {
  final MessageModel message;
  final bool estMoi;
  const _Bulle({required this.message, required this.estMoi});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: estMoi ? kCouleurPrimaire : kCouleurAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: estMoi ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}