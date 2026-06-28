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

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String bio;
  final List<String> skills; 
  final List<String> lookingFor;
  final Map<String, bool> availability;
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
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio = '',
    this.skills = const [],
    this.lookingFor = const [],
    this.availability = const {},
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      lookingFor: List<String>.from(data['lookingFor'] ?? []),
      availability: Map<String, bool>.from(data['availability'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'skills': skills,
      'lookingFor': lookingFor,
      'availability': availability,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? photoUrl,
    List<String>? skills,
    List<String>? lookingFor,
    Map<String, bool>? availability,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      lookingFor: lookingFor ?? this.lookingFor,
      availability: availability ?? this.availability,
      createdAt: createdAt,
    );
  }
}
