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