
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';


class SearchState {
  final List<UserModel> resultats;
  final bool chargement;
  final String? erreur;

  const SearchState({
    this.resultats = const [],
    this.chargement = false,
    this.erreur,
  });

  SearchState copyWith({
    List<UserModel>? resultats,
    bool? chargement,
    String? erreur,
    bool effacerErreur = false,
  }) {
    return SearchState(
      resultats: resultats ?? this.resultats,
      chargement: chargement ?? this.chargement,
      erreur: effacerErreur ? null : (erreur ?? this.erreur),
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  Future<void> searchStudents({
    String? skillFilter,     
    String? sectorFilter,
    String? levelFilter, 
    String? availabilityFilter,
  }) async {
    state = state.copyWith(chargement: true, effacerErreur: true);

    try {
      final currentUid = _ref.read(currentUserProvider)?.uid;

      Query query = _db.collection('users');

      if (skillFilter != null && skillFilter.isNotEmpty) {
        query = query.where('skills', arrayContains: skillFilter);
      }

      final snapshot = await query.get();

      List<UserModel> resultats = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((u) => u.uid != currentUid) // exclure soi-même
          .toList();

      if (sectorFilter != null && sectorFilter.isNotEmpty) {
        resultats = resultats
            .where((u) => u.sector == sectorFilter)
            .toList();
      }

      if (levelFilter != null && levelFilter.isNotEmpty) {
        resultats = resultats
            .where((u) => u.level == levelFilter)
            .toList();
      }

      if (availabilityFilter != null && availabilityFilter.isNotEmpty) {
        resultats = resultats
            .where((u) => u.availability[availabilityFilter] == true)
            .toList();
      }

      state = state.copyWith(chargement: false, resultats: resultats);
    } catch (e) {
      state = state.copyWith(
        chargement: false,
        erreur: 'Erreur de recherche : ${e.toString()}',
      );
    }
  }

  void vider() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});



class MatchController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendRequest({
    required String requesterId,
    required String targetUid,
  }) async {
    final existant = await _db
        .collection('matches')
        .where('requesterId', isEqualTo: requesterId)
        .where('receiverId', isEqualTo: targetUid)
        .get();

    final existantInverse = await _db
        .collection('matches')
        .where('requesterId', isEqualTo: targetUid)
        .where('receiverId', isEqualTo: requesterId)
        .get();

    if (existant.docs.isNotEmpty || existantInverse.docs.isNotEmpty) {
      throw Exception('Une demande existe déjà avec cet étudiant.');
    }

    await _db.collection('matches').add({
      'requesterId': requesterId,
      'receiverId': targetUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> respondToRequest(String matchId, bool accept) async {
    await _db.collection('matches').doc(matchId).update({
      'status': accept ? 'accepted' : 'refused',
    });
  }

  Stream<List<MatchModel>> getDemandesRecues(String uid) {
    return _db
        .collection('matches')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Stream<List<MatchModel>> getDemandesEnvoyees(String uid) {
    return _db
        .collection('matches')
        .where('requesterId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Stream<List<MatchModel>> getBinomesConfirmes(String uid) {
    final enTantQueRequester = _db
        .collection('matches')
        .where('requesterId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((s) => s.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());

    final enTantQueReceiver = _db
        .collection('matches')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((s) => s.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());
    return enTantQueRequester;
  }

  Stream<List<MatchModel>> getTousBinomesConfirmes(String uid) {
    return _db
        .collection('matches')
        .where('users', arrayContains: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }
}

// Provider du MatchController
final matchControllerProvider = Provider<MatchController>((ref) {
  return MatchController();
});
