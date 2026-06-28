// lib/screens/auth/login_screen.dart
// Écran de connexion — utilise Riverpod pour gérer l'état

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constantes.dart';
import '../../widgets/champ_texte.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  bool _voirPassword    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    if (!_formKey.currentState!.validate()) return;

    final succes = await ref.read(authProvider.notifier).connecter(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );


    if (!succes && mounted) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kPadding * 1.5,
            vertical: kPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: kCouleurPrimaire,
                ),
                const SizedBox(height: 16),
                const Text(
                  'TrouveTonBinôme',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kCouleurPrimaire,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Trouve le partenaire idéal pour tes projets',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kCouleurGris, fontSize: 14),
                ),

                const SizedBox(height: 40),

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

                ChampTexte(
                  label: 'Email universitaire',
                  controller: _emailCtrl,
                  clavier: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  onChanged: (_) => ref.read(authProvider.notifier).effacerErreur(),
                  validateur: (v) {
                    if (v == null || v.isEmpty) return 'L\'email est requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                ChampTexte(
                  label: 'Mot de passe',
                  controller: _passwordCtrl,
                  obscure: !_voirPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  onChanged: (_) => ref.read(authProvider.notifier).effacerErreur(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _voirPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _voirPassword = !_voirPassword),
                  ),
                  validateur: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _afficherDialogueMDP(context),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: kCouleurPrimaire),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                authState.chargement
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: kCouleurPrimaire,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _connecter,
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Pas encore de compte ?',
                        style: TextStyle(color: kCouleurGris, fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kCouleurPrimaire,
                    side: const BorderSide(color: kCouleurPrimaire),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadius),
                    ),
                  ),
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _afficherDialogueMDP(BuildContext context) {
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
        title: const Text('Mot de passe oublié'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entre ton email pour recevoir un lien de réinitialisation.',
              style: TextStyle(color: kCouleurGris, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ChampTexte(
              label: 'Email',
              controller: emailCtrl,
              clavier: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
            ),
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;

              final succes = await ref
                  .read(authProvider.notifier)
                  .reinitialiserMotDePasse(emailCtrl.text.trim());

              if (ctx.mounted) Navigator.pop(ctx);

              if (succes && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email de réinitialisation envoyé !'),
                    backgroundColor: kCouleurPrimaire,
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
