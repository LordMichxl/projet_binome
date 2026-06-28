
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/constantes.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MonApp(),
    ),
  );
}

class MonApp extends ConsumerWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TrouveTonBinôme',
      debugShowCheckedModeBanner: false,
      theme: kTheme,

      home: ref.watch(authStateProvider).when(
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: kCouleurPrimaire),
                SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: TextStyle(color: kCouleurGris),
                ),
              ],
            ),
          ),
        ),

        error: (error, _) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur de connexion à Firebase',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kCouleurGris),
                  ),
                ],
              ),
            ),
          ),
        ),

        data: (firebaseUser) {
          if (firebaseUser != null) {
            return const _ChargeurProfil();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class _ChargeurProfil extends ConsumerStatefulWidget {
  const _ChargeurProfil();

  @override
  ConsumerState<_ChargeurProfil> createState() => _ChargeurProfilState();
}

class _ChargeurProfilState extends ConsumerState<_ChargeurProfil> {
  bool _charge = false;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null && !_charge) {
      setState(() => _charge = true);
      await ref.read(authProvider.notifier).chargerProfilActuel();
      if (mounted) setState(() => _charge = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);


    if (_charge || authState.chargement) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kCouleurPrimaire),
              SizedBox(height: 16),
              Text('Chargement du profil...'),
            ],
          ),
        ),
      );
    }


    return const HomeScreen();
  }
}
