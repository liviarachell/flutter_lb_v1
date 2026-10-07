import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Painel azul-marinho com o topo arredondado (login e cadastro).
class AuthPanel extends StatelessWidget {
  const AuthPanel({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(56)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 36, 30, 24),
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center, style: AppText.playfair(28)),
            const SizedBox(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }
}
