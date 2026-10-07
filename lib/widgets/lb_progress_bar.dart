import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra de progresso de leitura (trilho branco + preenchimento em degradê).
class LbProgressBar extends StatelessWidget {
  const LbProgressBar({super.key, required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.progressStart, AppColors.progressEnd]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
