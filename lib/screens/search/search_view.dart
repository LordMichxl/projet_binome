
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_controller.dart';
import '../../utils/constantes.dart';
import '../../widgets/student_card.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  String _skillFiltre = '';
  String _sectorFiltre = '';
  String _levelFiltre = '';
  String _availabilityFiltre = '';

  // Pour savoir quels étudiants ont déjà une demande envoyée
  final Set<String> _demandesEnvoyees = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).searchStudents();
    });
  }

  Future<void> _lancerRecherche() async {
    await ref.read(searchProvider.notifier).searchStudents(
      skillFilter: _skillFiltre.isEmpty ? null : _skillFiltre,
      sectorFilter: _sectorFiltre.isEmpty ? null : _sectorFiltre,
      levelFilter: _levelFiltre.isEmpty ? null : _levelFiltre,
      availabilityFilter: _availabilityFiltre.isEmpty ? null : _availabilityFiltre,
    );
  }

  Future<void> _envoyerDemande(UserModel cible) async {
    final moi = ref.read(currentUserProvider);
    if (moi == null) return;

    try {
      await ref.read(matchControllerProvider).sendRequest(
        requesterId: moi.uid,
        targetUid: cible.uid,
      );

      setState(() => _demandesEnvoyees.add(cible.uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande envoyée à ${cible.name} !'),
            backgroundColor: kCouleurPrimaire,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un binôme'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              kPadding, kPaddingSmall, kPadding, kPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                _dropdownFiltre(
                  label: 'Compétence recherchée',
                  valeur: _skillFiltre,
                  options: kSkills,
                  icone: Icons.code,
                  onChanged: (v) => setState(() => _skillFiltre = v ?? ''),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _dropdownFiltre(
                        label: 'Filière',
                        valeur: _sectorFiltre,
                        options: kSectors,
                        icone: Icons.school_outlined,
                        onChanged: (v) =>
                            setState(() => _sectorFiltre = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filtre level (client)
                    Expanded(
                      child: _dropdownFiltre(
                        label: 'Niveau',
                        valeur: _levelFiltre,
                        options: kLevels,
                        icone: Icons.trending_up,
                        onChanged: (v) =>
                            setState(() => _levelFiltre = v ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _dropdownFiltre(
                  label: 'Disponible le...',
                  valeur: _availabilityFiltre,
                  options: kAvailabilityDefaut.keys.toList(),
                  icone: Icons.calendar_today,
                  onChanged: (v) =>
                      setState(() => _availabilityFiltre = v ?? ''),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _lancerRecherche,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Rechercher'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _skillFiltre = '';
                          _sectorFiltre = '';
                          _levelFiltre = '';
                          _availabilityFiltre = '';
                        });
                        ref.read(searchProvider.notifier).searchStudents();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kCouleurGris,
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadius),
                        ),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: searchState.chargement
                ? const Center(child: CircularProgressIndicator(
                    color: kCouleurPrimaire))

                : searchState.erreur != null
                    ? _messageErreur(searchState.erreur!)

                    : searchState.resultats.isEmpty
                        ? _messageVide()

                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              top: kPaddingSmall,
                              bottom: kPadding * 4,
                            ),
                            itemCount: searchState.resultats.length,
                            itemBuilder: (ctx, i) {
                              final etudiant = searchState.resultats[i];
                              return StudentCard(
                                etudiant: etudiant,
                                dejaMatch: _demandesEnvoyees
                                    .contains(etudiant.uid),
                                onVoirProfil: () =>
                                    _voirProfil(etudiant),
                                onEnvoyerDemande: _demandesEnvoyees
                                        .contains(etudiant.uid)
                                    ? null
                                    : () => _envoyerDemande(etudiant),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownFiltre({
    required String label,
    required String valeur,
    required List<String> options,
    required IconData icone,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: valeur.isEmpty ? null : valeur,
      hint: Text(label, style: const TextStyle(fontSize: 13)),
      decoration: InputDecoration(
        prefixIcon: Icon(icone, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      isExpanded: true,
      items: [
        DropdownMenuItem<String>(
          value: '',
          child: Text(
            'Tous',
            style: TextStyle(color: kCouleurGris, fontSize: 13),
          ),
        ),
        ...options.map((o) => DropdownMenuItem<String>(
              value: o,
              child: Text(o, style: const TextStyle(fontSize: 13)),
            )),
      ],
      onChanged: onChanged,
    );
  }
  Widget _messageVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: kCouleurGris.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun étudiant trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kCouleurGris,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Essaie de modifier les filtres',
            style: TextStyle(color: kCouleurGris),
          ),
        ],
      ),
    );
  }
  Widget _messageErreur(String erreur) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              erreur,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _lancerRecherche,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
  void _voirProfil(UserModel etudiant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProfilDetail(etudiant: etudiant),
    );
  }
}

class _ProfilDetail extends StatelessWidget {
  final UserModel etudiant;
  const _ProfilDetail({required this.etudiant});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.all(kPadding),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: kCouleurGris.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: kCouleurAccent,
                backgroundImage: etudiant.photoUrl != null
                    ? NetworkImage(etudiant.photoUrl!)
                    : null,
                child: etudiant.photoUrl == null
                    ? Text(
                        etudiant.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kCouleurPrimaire,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etudiant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${etudiant.sector} • ${etudiant.level}',
                    style: const TextStyle(color: kCouleurGris),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          _section('Compétences', etudiant.skills),

          if (etudiant.lookingFor.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section('Recherche', etudiant.lookingFor),
          ],

          const SizedBox(height: 12),
          const Text(
            'Disponibilités',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: etudiant.availability.entries
                .map((e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: e.value
                            ? kCouleurSecondaire
                            : kCouleurGris.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.key,
                        style: TextStyle(
                          color: e.value ? Colors.white : kCouleurGris,
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _section(String titre, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kCouleurAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
