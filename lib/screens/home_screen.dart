

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/constantes.dart';
import 'search/search_view.dart';
import 'matches/my_matches_view.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: _ecrans[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: kCouleurAccent,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: kCouleurPrimaire),
            label: 'Recherche',
          ),
          const NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake, color: kCouleurPrimaire),
            label: 'Mes binômes',
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
