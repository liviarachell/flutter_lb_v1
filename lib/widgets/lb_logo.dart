import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logotipo do lêBrasil (ícone em imagem + texto "lêBrasil" em fonte Asap).
class LbLogo extends StatelessWidget {
  const LbLogo({super.key, this.height = 100, this.wordmark = false, this.opacity = 1});

  /// Altura do ícone.
  final double height;
  final bool wordmark;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', height: height),
          if (wordmark) ...[
            SizedBox(height: height * 0.06),
            Text('lêBrasil', style: AppText.asap(height * 0.3)),
          ],
        ],
      ),
    );
  }
}
