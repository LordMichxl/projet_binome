// lib/services/auth_service.dart
// Toute la logique Firebase Auth : inscription, connexion, déconnexion

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> inscrire({
    required String email,
    required String password,
    required String name,
    required String sector,
    required String level,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        sector: sector,
        level: level,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Convertir le code d'erreur Firebase en message lisible
      throw Exception(_messageErreur(e.code));
    }
  }

  Future<UserModel> connecter({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Profil introuvable. Contactez le support.');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageErreur(e.code));
    }
  }

  Future<void> deconnecter() async {
    await _auth.signOut();
  }

  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageErreur(e.code));
    }
  }

  Future<UserModel?> getProfilActuel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data()!);
  }


  String _messageErreur(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      case 'invalid-email':
        return 'L\'adresse email n\'est pas valide.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'network-request-failed':
        return 'Pas de connexion internet. Vérifiez votre réseau.';
      default:
        return 'Une erreur est survenue ($code). Réessayez.';
    }
  }
}
