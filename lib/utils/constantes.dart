// lib/utils/constantes.dart
// Toutes les constantes réutilisables dans l'application

import 'package:flutter/material.dart';

const Color kCouleurPrimaire   = Color(0xFF2D6A4F); // vert foncé
const Color kCouleurSecondaire = Color(0xFF52B788); // vert clair
const Color kCouleurAccent     = Color(0xFFB7E4C7); // vert très clair
const Color kCouleurFond       = Color(0xFFF8F9FA); // gris clair
const Color kCouleurTexte      = Color(0xFF1B1B1B); // presque noir
const Color kCouleurGris       = Color(0xFF8D99AE); // gris moyen

const double kPadding      = 16.0;
const double kPaddingSmall = 8.0;
const double kRadius       = 12.0;

const List<String> kFilieres = [
  'Informatique',
  'Réseaux & Télécoms',
  'Génie Logiciel',
  'Intelligence Artificielle',
  'Cybersécurité',
  'Data Science',
  'Autre',
];

const List<String> kNiveaux = [
  'L1', 'L2', 'L3', 'M1', 'M2',
];

const List<String> kCompetences = [
  'Flutter', 'Dart', 'Python', 'Java', 'JavaScript',
  'React', 'Node.js', 'Firebase', 'SQL', 'MongoDB',
  'C++', 'C', 'PHP', 'Laravel', 'Spring Boot',
  'Machine Learning', 'Linux', 'Git', 'Docker', 'AWS',
];

const List<String> kDisponibilites = [
  'Lundi matin', 'Lundi après-midi', 'Lundi soir',
  'Mardi matin', 'Mardi après-midi', 'Mardi soir',
  'Mercredi matin', 'Mercredi après-midi', 'Mercredi soir',
  'Jeudi matin', 'Jeudi après-midi', 'Jeudi soir',
  'Vendredi matin', 'Vendredi après-midi', 'Vendredi soir',
  'Samedi matin', 'Samedi après-midi',
];

ThemeData get kTheme => ThemeData(
  primaryColor: kCouleurPrimaire,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kCouleurPrimaire,
    primary: kCouleurPrimaire,
    secondary: kCouleurSecondaire,
  ),
  scaffoldBackgroundColor: kCouleurFond,
  appBarTheme: const AppBarTheme(
    backgroundColor: kCouleurPrimaire,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kCouleurPrimaire,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadius),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadius),
      borderSide: const BorderSide(color: kCouleurPrimaire, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadius),
      borderSide: const BorderSide(color: Colors.red),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadius),
    ),
    color: Colors.white,
  ),
);
