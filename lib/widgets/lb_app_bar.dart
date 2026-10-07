import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'lb_logo.dart';

/// Barra superior da home: hambúrguer à esquerda e logo à direita.
class LbAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LbAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Material(
      color: dark ? AppColors.slate : Colors.white,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 32,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(Icons.menu, color: dark ? Colors.white : AppColors.navy),
                ),
                const LbLogo(height: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
