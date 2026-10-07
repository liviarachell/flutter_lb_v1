import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../theme/app_theme.dart';

/// Menu lateral: foto/nome, atalhos e alternância claro/escuro.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _items = [
    ('Perfil', '/perfil'),
    ('Seu Progresso', '/progresso'),
    ('Suas Leituras', '/leituras'),
    ('Encontre Novas Obras', '/encontrar'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width * 0.72).clamp(260.0, 340.0);
    return Drawer(
      width: width,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(48)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: currentUser,
                builder: (_, user, _) => Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.person, size: 44, color: AppColors.slate),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        user.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.poppins(20, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 5,
                width: width * 0.7,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 14),
              for (final item in _items)
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(item.$2);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF0F2050), width: 1.5)),
                    ),
                    child: Text(item.$1, style: AppText.gelasio(21)),
                  ),
                ),
              const Spacer(),
              const _ThemeSwitch(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternador lua (escuro) / sol (claro).
class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeController,
      builder: (_, mode, _) {
        final dark = mode == ThemeMode.dark;
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: 120,
            height: 44,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => themeController.value = ThemeMode.dark,
                    child: Container(
                      color: const Color(0xFF050B18),
                      alignment: Alignment.center,
                      child: Icon(Icons.nightlight_round, color: Colors.white.withValues(alpha: dark ? 1 : 0.45)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => themeController.value = ThemeMode.light,
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Icon(Icons.wb_sunny_outlined, color: Colors.black.withValues(alpha: dark ? 0.45 : 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
