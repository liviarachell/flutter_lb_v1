import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botão circular de voltar (seta dentro de um círculo).
class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.headingColor;
    return InkResponse(
      onTap: onPressed ??
          () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              nav.pushReplacementNamed('/home');
            }
          },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(Icons.chevron_left, color: color, size: 28),
      ),
    );
  }
}
