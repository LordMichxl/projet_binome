class UserModel {
  final String uid;
  final String email;
  final String nom;
  final String prenom;
  final String filiere;
  final String niveau;
  final String? photoUrl;
  final List<String> competences;
  final List<String> disponibilites;
  final double noteMoyenne;
  final int nombreNotes;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.filiere,
    required this.niveau,
    this.photoUrl,
    this.competences = const [],
    this.disponibilites = const [],
    this.noteMoyenne = 0.0,
    this.nombreNotes = 0,
    required this.createdAt,
  });

  String get nomComplet => '$prenom $nom';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'filiere': filiere,
      'niveau': niveau,
      'photoUrl': photoUrl,
      'competences': competences,
      'disponibilites': disponibilites,
      'noteMoyenne': noteMoyenne,
      'nombreNotes': nombreNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      filiere: map['filiere'] ?? '',
      niveau: map['niveau'] ?? '',
      photoUrl: map['photoUrl'],
      competences: List<String>.from(map['competences'] ?? []),
      disponibilites: List<String>.from(map['disponibilites'] ?? []),
      noteMoyenne: (map['noteMoyenne'] ?? 0.0).toDouble(),
      nombreNotes: map['nombreNotes'] ?? 0,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
