// lib/providers/auth_provider.dart
// Gestion de l'état de l'authentification avec Riverpod
//
// Riverpod = comme Provider mais plus puissant.
// Un "provider" = une source de données que les widgets peuvent écouter.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthState {
  final bool chargement;
  final String? erreur;
  final UserModel? user;

  const AuthState({
    this.chargement = false,
    this.erreur,
    this.user,
  });

  AuthState copyWith({
    bool? chargement,
    String? erreur,
    UserModel? user,
    bool effacerErreur = false,
    bool effacerUser = false,
  }) {
    return AuthState(
      chargement: chargement ?? this.chargement,
      erreur: effacerErreur ? null : (erreur ?? this.erreur),
      user: effacerUser ? null : (user ?? this.user),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<bool> inscrire({
    required String email,
    required String password,
    required String name,
    required String sector,
    required String level,
  }) async {
    state = state.copyWith(chargement: true, effacerErreur: true);

    try {
      final user = await _authService.inscrire(
        email: email,
        password: password,
        name: name,
        sector: sector,
        level: level,
      );

      state = state.copyWith(chargement: false, user: user);
      return true; // succès
    } catch (e) {
      state = state.copyWith(
        chargement: false,
        erreur: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> connecter({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(chargement: true, effacerErreur: true);

    try {
      final user = await _authService.connecter(
        email: email,
        password: password,
      );

      state = state.copyWith(chargement: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        chargement: false,
        erreur: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> deconnecter() async {
    await _authService.deconnecter();
    state = const AuthState();
  }

  Future<bool> reinitialiserMotDePasse(String email) async {
    state = state.copyWith(chargement: true, effacerErreur: true);

    try {
      await _authService.reinitialiserMotDePasse(email);
      state = state.copyWith(chargement: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        chargement: false,
        erreur: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> chargerProfilActuel() async {
    final user = await _authService.getProfilActuel();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  void effacerErreur() {
    state = state.copyWith(effacerErreur: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});


final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
