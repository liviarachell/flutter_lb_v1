import 'package:flutter/material.dart';

import 'bottom_menu.dart';
import 'gradient_background.dart';
import 'round_back_button.dart';

/// Estrutura comum das telas: degradê, botão voltar e menu inferior flutuante.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.menuIndex,
    this.showBack = false,
    this.onBack,
    this.appBar,
    this.drawer,
  });

  final Widget child;

  /// Aba destacada no menu inferior (0 perfil, 1 início, 2 busca). Nulo = sem menu.
  final int? menuIndex;
  final bool showBack;
  final VoidCallback? onBack;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;

  /// Espaço que o conteúdo deve deixar no fim para não ficar atrás do menu.
  static const double menuClearance = 110;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: GradientBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: RoundBackButton(onPressed: onBack),
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
            if (menuIndex != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Center(child: BottomMenu(currentIndex: menuIndex!)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
