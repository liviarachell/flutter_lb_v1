import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Menu flutuante inferior: perfil, início e busca.
class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key, required this.currentIndex});

  /// 0 = perfil, 1 = início, 2 = buscar.
  final int currentIndex;

  static const _routes = ['/perfil', '/home', '/encontrar'];
  static const _icons = [
    (Icons.person_outline, Icons.person),
    (Icons.home_outlined, Icons.home),
    (Icons.search, Icons.search),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      width: 250,
      height: 62,
      decoration: BoxDecoration(
        color: dark ? AppColors.slate : Colors.white,
        borderRadius: BorderRadius.circular(31),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < _routes.length; i++)
            IconButton(
              iconSize: 30,
              onPressed: () {
                if (i == currentIndex) return;
                Navigator.of(context).pushNamedAndRemoveUntil(_routes[i], (_) => false);
              },
              icon: Icon(
                i == currentIndex ? _icons[i].$2 : _icons[i].$1,
                color: dark ? Colors.white : AppColors.navy,
              ),
            ),
        ],
      ),
    );
  }
}
