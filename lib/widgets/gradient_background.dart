import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fundo em degradê azul usado em todas as telas.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDark
              ? const [AppColors.darkTop, AppColors.darkBottom]
              : const [AppColors.skyTop, AppColors.skyBottom],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
