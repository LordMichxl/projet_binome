import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constantes.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _sectorController;
  final TextEditingController _skillController = TextEditingController();

  static const List<String> _levels = ['L1', 'L2', 'L3', 'M1', 'M2'];
  static const List<String> _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _sectorController = TextEditingController(text: user?.sector ?? '');
    _selectedLevel = (user != null && _levels.contains(user.level)) ? user.level : 'L3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectorController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) return;
    ref.read(authProvider.notifier).addSkill(skill);
    _skillController.clear();
  }

  void _save() {
    ref.read(authProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      sector: _sectorController.text.trim(),
      level: _selectedLevel,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom')),
            const SizedBox(height: 12),
            TextField(
              controller: _sectorController,
              decoration: const InputDecoration(labelText: 'Filière (ex: CSI)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: 'Niveau'),
              items: _levels.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedLevel = value);
              },
            ),
            const SizedBox(height: 20),
            const Text('Compétences', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (user?.skills ?? []).map((skill) {
                return Chip(
                  label: Text(skill),
                  onDeleted: () => ref.read(authProvider.notifier).removeSkill(skill),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter une compétence',
                      hintText: 'ex: Flutter',
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addSkill),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Disponibilités', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                final isAvailable = user?.availability[day] ?? false;
                return FilterChip(
                  label: Text(day),
                  selected: isAvailable,
                  onSelected: (_) => ref.read(authProvider.notifier).toggleAvailability(day),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}