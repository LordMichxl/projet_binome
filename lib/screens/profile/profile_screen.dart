import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constantes.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Profil introuvable')));
    }

    final availableDays =
        user.availability.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: kCouleurAccent,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 28, color: kCouleurPrimaire),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall)),
            Center(child: Text(user.email, style: const TextStyle(color: kCouleurGris))),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(avatar: const Icon(Icons.school, size: 18), label: Text(user.level)),
                  Chip(avatar: const Icon(Icons.computer, size: 18), label: Text(user.sector)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Compétences', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            user.skills.isEmpty
                ? const Text('Aucune compétence renseignée', style: TextStyle(color: kCouleurGris))
                : Wrap(spacing: 8, children: user.skills.map((s) => Chip(label: Text(s))).toList()),
            const SizedBox(height: 24),
            const Text('Disponibilités', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            availableDays.isEmpty
                ? const Text('Aucune disponibilité renseignée', style: TextStyle(color: kCouleurGris))
                : Wrap(
                    spacing: 8,
                    children: availableDays
                        .map((day) => Chip(
                              avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              label: Text(day),
                            ))
                        .toList(),
                  ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}