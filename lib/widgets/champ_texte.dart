// lib/widgets/champ_texte.dart
// Champ de formulaire stylisé et réutilisable dans toute l'app

import 'package:flutter/material.dart';

class ChampTexte extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType clavier;
  final String? Function(String?)? validateur;
  final int maxLignes;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const ChampTexte({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.clavier = TextInputType.text,
    this.validateur,
    this.maxLignes = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: clavier,
      maxLines: obscure ? 1 : maxLignes,
      validator: validateur,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
