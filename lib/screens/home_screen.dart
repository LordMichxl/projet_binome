import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_controller.dart';
import '../utils/constantes.dart';
import 'search/search_view.dart';
import 'matches/my_matches_view.dart';
import 'chat/chat_list_view.dart';
import 'profile/profile_screen.dart';
import 'notifications/notification_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  final List<Widget> _ecrans = const [
    SearchView(),
    MyMatchesView(),
    ChatListView(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final moi = ref.watch(currentUserProvider);
    final notifController = ref.read(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrouveTonBinôme'),
        actions: [
          if (moi != null)
            StreamBuilder<int>(
              stream: notifController.getCompteurNonLues(moi.uid),
              builder: (ctx, snap) {
                final compteur = snap.data ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationView()),
                      ),
                    ),
                    if (compteur > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            compteur > 9 ? '9+' : '$compteur',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: _ecrans[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: kCouleurAccent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: kCouleurPrimaire),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake, color: kCouleurPrimaire),
            label: 'Mes binômes',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: kCouleurPrimaire),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: kCouleurPrimaire),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: kCouleurGris.withOpacity(0.15),
        elevation: 0,
        tooltip: 'Déconnexion',
        onPressed: () async {
          await ref.read(authProvider.notifier).deconnecter();
        },
        child: const Icon(Icons.logout, color: kCouleurGris),
      ),
    );
  }
}