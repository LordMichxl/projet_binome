// lib/screens/auth/register_screen.dart
// Écran d'inscription en 2 étapes : infos perso + infos académiques

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constantes.dart';
import '../../widgets/champ_texte.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  int _etapeActuelle   = 0;

  final _nameCtrl    = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  String _filiereChoisie = kFilieres.first;
  String _niveauChoisi   = kNiveaux.first;
  bool _voirPassword     = false;
  bool _voirConfirm      = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _etapeSuivante() {
    if (_formKey.currentState!.validate()) {
      setState(() => _etapeActuelle = 1);
    }
  }

  void _etapePrecedente() {
    setState(() => _etapeActuelle = 0);
  }

  Future<void> _inscrire() async {
    if (!_formKey.currentState!.validate()) return;

    final succes = await ref.read(authProvider.notifier).inscrire(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      sector: _filiereChoisie,
      level: _niveauChoisi,
    );

    if (!succes && mounted) {
      setState(() => _etapeActuelle = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _etapeActuelle == 0
              ? () => Navigator.pop(context)
              : _etapePrecedente,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _indicateurEtape(),
              const SizedBox(height: 24),

              if (authState.erreur != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(kRadius),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.erreur!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              _etapeActuelle == 0
                  ? _etapeInfosPerso()
                  : _etapeInfosAcademiques(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicateurEtape() {
    return Row(
      children: [
        _cercleEtape(1, _etapeActuelle >= 0, 'Infos\npersonnelles'),
        Expanded(
          child: Container(
            height: 2,
            color: _etapeActuelle >= 1
                ? kCouleurPrimaire
                : kCouleurGris.withOpacity(0.3),
          ),
        ),
        _cercleEtape(2, _etapeActuelle >= 1, 'Infos\nacadémiques'),
      ],
    );
  }

  Widget _cercleEtape(int numero, bool actif, String label) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: actif ? kCouleurPrimaire : kCouleurGris.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$numero',
              style: TextStyle(
                color: actif ? Colors.white : kCouleurGris,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: actif ? kCouleurPrimaire : kCouleurGris,
          ),
        ),
      ],
    );
  }

  Widget _etapeInfosPerso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Informations personnelles',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ChampTexte(
                label: 'Nom complet',
                controller: _nameCtrl,
                onChanged: (_) =>
                    ref.read(authProvider.notifier).effacerErreur(),
                validateur: (v) =>
                    v!.trim().isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ChampTexte(
          label: 'Email universitaire',
          controller: _emailCtrl,
          clavier: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          onChanged: (_) =>
              ref.read(authProvider.notifier).effacerErreur(),
          validateur: (v) {
            if (v == null || v.isEmpty) return 'Email requis';
            if (!v.contains('@')) return 'Email invalide';
            return null;
          },
        ),
        const SizedBox(height: 14),

        ChampTexte(
          label: 'Mot de passe (min. 6 caractères)',
          controller: _passwordCtrl,
          obscure: !_voirPassword,
          prefixIcon: const Icon(Icons.lock_outline),
          onChanged: (_) =>
              ref.read(authProvider.notifier).effacerErreur(),
          suffixIcon: IconButton(
            icon: Icon(_voirPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () =>
                setState(() => _voirPassword = !_voirPassword),
          ),
          validateur: (v) {
            if (v == null || v.isEmpty) return 'Mot de passe requis';
            if (v.length < 6) return 'Minimum 6 caractères';
            return null;
          },
        ),
        const SizedBox(height: 14),

        ChampTexte(
          label: 'Confirmer le mot de passe',
          controller: _confirmCtrl,
          obscure: !_voirConfirm,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_voirConfirm
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () =>
                setState(() => _voirConfirm = !_voirConfirm),
          ),
          validateur: (v) {
            if (v == null || v.isEmpty) return 'Confirmation requise';
            if (v != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
            return null;
          },
        ),

        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: _etapeSuivante,
          child: const Text('Suivant →', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _etapeInfosAcademiques() {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Informations académiques',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ces informations servent à trouver des binômes compatibles.',
          style: TextStyle(color: kCouleurGris, fontSize: 13),
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: _filiereChoisie,
          decoration: InputDecoration(
            labelText: 'Filière',
            prefixIcon: const Icon(Icons.school_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: kFilieres
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (v) => setState(() => _filiereChoisie = v!),
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: _niveauChoisi,
          decoration: InputDecoration(
            labelText: 'Niveau d\'étude',
            prefixIcon: const Icon(Icons.trending_up),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kRadius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: kNiveaux
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => setState(() => _niveauChoisi = v!),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCouleurAccent.withOpacity(0.4),
            borderRadius: BorderRadius.circular(kRadius),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: kCouleurPrimaire, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tu pourras ajouter tes compétences et disponibilités depuis ton profil après l\'inscription.',
                  style: TextStyle(
                    color: kCouleurPrimaire,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        authState.chargement
            ? const Center(
                child: CircularProgressIndicator(color: kCouleurPrimaire),
              )
            : ElevatedButton(
                onPressed: _inscrire,
                child: const Text(
                  'Créer mon compte',
                  style: TextStyle(fontSize: 16),
                ),
              ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _etapePrecedente,
          child: const Text(
            '← Retour',
            style: TextStyle(color: kCouleurGris),
          ),
        ),
      ],
    );
  }
}
