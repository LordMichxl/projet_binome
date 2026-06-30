
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_controller.dart';
import '../../utils/constantes.dart';

class MyMatchesView extends ConsumerStatefulWidget {
  const MyMatchesView({super.key});

  @override
  ConsumerState<MyMatchesView> createState() => _MyMatchesViewState();
}

class _MyMatchesViewState extends ConsumerState<MyMatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moi = ref.watch(currentUserProvider);
    if (moi == null) return const SizedBox.shrink();

    final controller = ref.read(matchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Binômes'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.inbox_outlined), text: 'Reçues'),
            Tab(icon: Icon(Icons.send_outlined), text: 'Envoyées'),
            Tab(icon: Icon(Icons.handshake_outlined), text: 'Confirmés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [

          _OngletMatches(
            stream: controller.getDemandesRecues(moi.uid),
            uid: moi.uid,
            type: _TypeOnglet.recues,
          ),
 
          _OngletMatches(
            stream: controller.getDemandesEnvoyees(moi.uid),
            uid: moi.uid,
            type: _TypeOnglet.envoyees,
          ),

          _BinomesConfirmes(uid: moi.uid),
        ],
      ),
    );
  }
}

enum _TypeOnglet { recues, envoyees }

class _OngletMatches extends ConsumerWidget {
  final Stream<List<MatchModel>> stream;
  final String uid;
  final _TypeOnglet type;

  const _OngletMatches({
    required this.stream,
    required this.uid,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<MatchModel>>(
      stream: stream,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: kCouleurPrimaire));
        }

        final matches = snapshot.data ?? [];

        if (matches.isEmpty) {
          return _vide(type);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: kPaddingSmall),
          itemCount: matches.length,
          itemBuilder: (ctx2, i) => _CarteMatch(
            match: matches[i],
            myUid: uid,
            type: type,
          ),
        );
      },
    );
  }

  Widget _vide(_TypeOnglet type) {
    final message = type == _TypeOnglet.recues
        ? 'Aucune demande reçue pour le moment'
        : 'Vous n\'avez envoyé aucune demande';
    final icone = type == _TypeOnglet.recues
        ? Icons.inbox_outlined
        : Icons.send_outlined;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 64, color: kCouleurGris.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: kCouleurGris, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CarteMatch extends ConsumerWidget {
  final MatchModel match;
  final String myUid;
  final _TypeOnglet type;

  const _CarteMatch({
    required this.match,
    required this.myUid,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchControllerProvider);

    // L'autre utilisateur dans ce match
    final autreUid = match.requesterId == myUid
        ? match.receiverId
        : match.requesterId;

    return FutureBuilder<UserModel?>(
      future: controller.getUserById(autreUid),
      builder: (ctx, snap) {
        final autre = snap.data;

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
                      backgroundColor: kCouleurAccent,
                      backgroundImage: autre?.photoUrl != null
                          ? NetworkImage(autre!.photoUrl!)
                          : null,
                      child: autre?.photoUrl == null
                          ? Text(
                              autre?.name.isNotEmpty == true
                                  ? autre!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: kCouleurPrimaire,
                                fontWeight: FontWeight.bold,
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
                            autre?.name ?? 'Chargement...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (autre != null)
                            Text(
                              '${autre.sector} • ${autre.level}',
                              style: const TextStyle(
                                color: kCouleurGris,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Badge statut
                    _badgeStatut(match.status),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Demande du ${_formatDate(match.createdAt)}',
                    style: const TextStyle(
                      color: kCouleurGris,
                      fontSize: 12,
                    ),
                  ),
                ),

                if (type == _TypeOnglet.recues) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Refuser
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _repondre(context, ref, match.id, false),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadius),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Accepter
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _repondre(context, ref, match.id, true),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Accepter'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (type == _TypeOnglet.envoyees) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty,
                            size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Text(
                          'En attente de réponse...',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badgeStatut(MatchStatus status) {
    Color couleur;
    String texte;
    switch (status) {
      case MatchStatus.pending:
        couleur = Colors.orange;
        texte = 'En attente';
        break;
      case MatchStatus.accepted:
        couleur = kCouleurPrimaire;
        texte = 'Accepté';
        break;
      case MatchStatus.refused:
        couleur = Colors.red;
        texte = 'Refusé';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withOpacity(0.4)),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _repondre(
    BuildContext context,
    WidgetRef ref,
    String matchId,
    bool accepter,
  ) async {
    try {
      await ref
          .read(matchControllerProvider)
          .respondToRequest(matchId, accepter);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accepter
                  ? 'Binôme accepté ! Vous êtes maintenant partenaires.'
                  : 'Demande refusée.',
            ),
            backgroundColor: accepter ? kCouleurPrimaire : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _BinomesConfirmes extends ConsumerWidget {
  final String uid;
  const _BinomesConfirmes({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(matchControllerProvider);

  
    final streamRequester = controller.getBinomesConfirmes(uid);

  
    final streamReceiver = ref
        .read(matchControllerProvider)
        ._db
        .collection('matches')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((s) => s.docs
            .map((d) => MatchModel.fromFirestore(d.data(), d.id))
            .toList());

    return StreamBuilder<List<MatchModel>>(
      stream: streamRequester,
      builder: (ctx, snapR) {
        return StreamBuilder<List<MatchModel>>(
          stream: streamReceiver,
          builder: (ctx2, snapRec) {
            if (snapR.connectionState == ConnectionState.waiting ||
                snapRec.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: kCouleurPrimaire));
            }

            final tous = [
              ...(snapR.data ?? []),
              ...(snapRec.data ?? []),
            ];

            if (tous.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 64,
                      color: kCouleurGris.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun binôme confirmé pour le moment',
                      style: TextStyle(color: kCouleurGris, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Acceptez une demande pour former un binôme !',
                      style: TextStyle(color: kCouleurGris, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: kPaddingSmall),
              itemCount: tous.length,
              itemBuilder: (ctx3, i) => _CarteBinomeConfirme(
                match: tous[i],
                myUid: uid,
              ),
            );
          },
        );
      },
    );
  }
}

class _CarteBinomeConfirme extends ConsumerWidget {
  final MatchModel match;
  final String myUid;

  const _CarteBinomeConfirme({required this.match, required this.myUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autreUid =
        match.requesterId == myUid ? match.receiverId : match.requesterId;
    final controller = ref.read(matchControllerProvider);

    return FutureBuilder<UserModel?>(
      future: controller.getUserById(autreUid),
      builder: (ctx, snap) {
        final autre = snap.data;

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: kPadding,
            vertical: kPaddingSmall,
          ),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kCouleurAccent,
                  backgroundImage: autre?.photoUrl != null
                      ? NetworkImage(autre!.photoUrl!)
                      : null,
                  child: autre?.photoUrl == null
                      ? Text(
                          autre?.name.isNotEmpty == true
                              ? autre!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: kCouleurPrimaire,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        autre?.name ?? '...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (autre != null)
                        Text(
                          '${autre.sector} • ${autre.level}',
                          style: const TextStyle(
                            color: kCouleurGris,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Badge "Binôme confirmé"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kCouleurPrimaire.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 12, color: kCouleurPrimaire),
                            SizedBox(width: 4),
                            Text(
                              'Binôme confirmé',
                              style: TextStyle(
                                color: kCouleurPrimaire,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.handshake,
                  color: kCouleurSecondaire,
                  size: 32,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension MatchControllerExt on MatchController {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
}
