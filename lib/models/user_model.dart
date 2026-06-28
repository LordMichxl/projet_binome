import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String sector;
  final String level;
  final String? photoUrl;
  final List<String> skills;
  final List<String> lookingFor;
  final Map<String, bool> availability; 
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.sector,
    required this.level,
    this.photoUrl,
    this.skills = const [],
    this.lookingFor = const [],
    this.availability = const {},
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'sector': sector,
      'level': level,
      'photoUrl': photoUrl,
      'skills': skills,
      'lookingFor': lookingFor,
      'availability': availability,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      sector: map['sector'] ?? '',
      level: map['leve'] ?? '',
      photoUrl: map['photoUrl'],
      skills: List<String>.from(map['skills'] ?? []),
      lookingFor: List<String>.from(map['lookingFor'] ?? []),
      availability: Map<String, bool>.from(map['availability'] ?? {}),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
    UserModel copyWith({
    String? name,
    String? photoUrl,
    String? sector,
    String? level,
    List<String>? skills,
    List<String>? lookingFor,
    Map<String, bool>? availability,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      sector: sector ?? this.sector,
      level: level ?? this.level,
      skills: skills ?? this.skills,
      lookingFor: lookingFor ?? this.lookingFor,
      availability: availability ?? this.availability,
      createdAt: createdAt,
    );
  }

}
  
 


