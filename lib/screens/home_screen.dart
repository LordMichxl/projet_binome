// lib/screens/home_screen.dart
// Écran principal (placeholder) — à compléter par Michel avec les autres fonctionnalités

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/constantes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrouveTonBinôme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ref.read(authProvider.notifier).deconnecter();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: kCouleurAccent,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: kCouleurPrimaire,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Bienvenue, ${user?.name ?? ''} ',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${user?.sector ?? ''} - ${user?.level ?? ''}',
              style: const TextStyle(color: kCouleurGris),
            ),

            const SizedBox(height: 40),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: kPadding * 2),
              padding: const EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                color: kCouleurAccent.withOpacity(0.4),
                borderRadius: BorderRadius.circular(kRadius),
              ),
              child: const Column(
                children: [
                  Icon(Icons.construction, color: kCouleurPrimaire, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Les autres fonctionnalités seront ajoutées ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kCouleurPrimaire),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
