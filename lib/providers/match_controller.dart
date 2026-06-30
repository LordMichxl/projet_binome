
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';
import 'notification_controller.dart';
import '../models/notification_model.dart';

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
          .where((u) => u.uid != currentUid)
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
final NotificationController _notifController = NotificationController();
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
      'users': [requesterId, targetUid],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final demandeur = await getUserById(requesterId);
    await _notifController.creerNotification(
      targetUid: targetUid,
      type: NotificationType.matchRequest,
      message: '${demandeur?.name ?? "Un étudiant"} veut être ton binôme',
    );
  }

  Future<void> respondToRequest(String matchId, bool accept) async {
    await _db.collection('matches').doc(matchId).update({
      'status': accept ? 'accepted' : 'refused',
    });

    if (accept) {
      final matchDoc = await _db.collection('matches').doc(matchId).get();
      final data = matchDoc.data();
      if (data == null) return;

      final requesterId = data['requesterId'] as String;
      final receiverId = data['receiverId'] as String;

      await _creerChatSiInexistant(requesterId, receiverId);

      final accepteur = await getUserById(receiverId);
      await _notifController.creerNotification(
        targetUid: requesterId,
        type: NotificationType.matchAccepted,
        message: '${accepteur?.name ?? "Ton binôme"} a accepté ta demande !',
      );
    }
  }
  Future<void> _creerChatSiInexistant(String uid1, String uid2) async {
    final existant = await _db
        .collection('chats')
        .where('participants', arrayContains: uid1)
        .get();

    final dejaExistant = existant.docs.any((doc) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      return participants.contains(uid2);
    });

    if (dejaExistant) return;

    await _db.collection('chats').add({
      'participants': [uid1, uid2],
      'lastMessage': '',
      'lastMessageAt': null,
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
          .map((d) => MatchModel.fromMap(d.data(), d.id))
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
        .map((d) => MatchModel.fromMap(d.data(), d.id))
        .toList());
  }


  Stream<List<MatchModel>> getTousBinomesConfirmes(String uid) {
    return _db
        .collection('matches')
        .where('users', arrayContains: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snap) => snap.docs
          .map((d) => MatchModel.fromMap(d.data(), d.id))
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
