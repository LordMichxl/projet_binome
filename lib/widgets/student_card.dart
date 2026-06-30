
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constantes.dart';

class StudentCard extends StatelessWidget {
  final UserModel etudiant;
  final VoidCallback? onEnvoyerDemande;
  final VoidCallback? onVoirProfil;
  final bool dejaMatch;

  const StudentCard({
    super.key,
    required this.etudiant,
    this.onEnvoyerDemande,
    this.onVoirProfil,
    this.dejaMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: kPadding,
        vertical: kPaddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kCouleurAccent,
                  backgroundImage: etudiant.photoUrl != null
                      ? NetworkImage(etudiant.photoUrl!)
                      : null,
                  child: etudiant.photoUrl == null
                      ? Text(
                          etudiant.name.isNotEmpty
                              ? etudiant.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kCouleurPrimaire,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etudiant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _badge(etudiant.sector, kCouleurPrimaire),
                          const SizedBox(width: 6),
                          _badge(etudiant.level, kCouleurSecondaire),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (etudiant.skills.isNotEmpty) ...[
              const Text(
                'Compétences :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kCouleurGris,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: etudiant.skills
                    .take(4)
                    .map((s) => _chip(s))
                    .toList(),
              ),
              if (etudiant.skills.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${etudiant.skills.length - 4} de plus',
                    style: const TextStyle(
                      color: kCouleurGris,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],

            if (etudiant.lookingFor.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Recherche :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kCouleurGris,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: etudiant.lookingFor
                    .take(3)
                    .map((s) => _chip(s, couleur: kCouleurAccent.withOpacity(0.6)))
                    .toList(),
              ),
            ],

            if (etudiant.availability.values.any((v) => v)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: kCouleurGris,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _joursDisponibles(etudiant.availability),
                    style: const TextStyle(
                      color: kCouleurGris,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVoirProfil,
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('Profil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kCouleurPrimaire,
                      side: const BorderSide(color: kCouleurPrimaire),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: dejaMatch
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Demande envoyée'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kCouleurGris,
                            side: BorderSide(
                                color: kCouleurGris.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: onEnvoyerDemande,
                          icon: const Icon(Icons.handshake_outlined, size: 16),
                          label: const Text('Demander'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadius),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chip(String texte, {Color? couleur}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur ?? kCouleurAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: const TextStyle(fontSize: 12, color: kCouleurTexte),
      ),
    );
  }

  // Retourne les jours disponibles sous forme lisible : "Lundi, Mercredi..."
  String _joursDisponibles(Map<String, bool> availability) {
    final jours = availability.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (jours.isEmpty) return 'Aucune dispo renseignée';
    if (jours.length <= 3) return jours.join(', ');
    return '${jours.take(3).join(', ')} +${jours.length - 3}';
  }
}
