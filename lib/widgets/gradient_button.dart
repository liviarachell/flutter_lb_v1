import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botão em degradê azul (Entrar, Cadastrar, Continuar).
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 54,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: const LinearGradient(colors: [AppColors.buttonStart, AppColors.buttonEnd]),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onPressed,
          child: Center(
            child: Text(label, style: textStyle ?? AppText.playfair(22)),
          ),
        ),
      ),
    );
  }
}
