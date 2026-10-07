import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/lb_logo.dart';
import '../widgets/page_scaffold.dart';

/// Avatar circular com o lápis de edição (usado no perfil e na edição).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 160,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.inputFill, width: 3),
              ),
              child: const Icon(Icons.person_outline, size: 100, color: AppColors.inputFill),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inputFill, width: 3),
                ),
                child: const Icon(Icons.edit_outlined, color: AppColors.inputFill, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rótulo acima dos campos do perfil ("Nome Completo", "Email"...).
class ProfileLabel extends StatelessWidget {
  const ProfileLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6, top: 14),
      child: Text(text, style: AppText.gelasio(16, color: context.headingColor, weight: FontWeight.w700)),
    );
  }
}

/// Campo somente leitura do perfil (fundo azul-ardósia, texto branco).
class ProfileField extends StatelessWidget {
  const ProfileField({super.key, required this.text, this.showEye = false});

  final String text;
  final bool showEye;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(color: AppColors.slate, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.poppins(16))),
          if (showEye) const Icon(Icons.visibility_off, color: Colors.white),
        ],
      ),
    );
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    void edit() => Navigator.of(context).pushNamed('/editar-perfil');

    return PageScaffold(
      showBack: true,
      menuIndex: 0,
      child: ValueListenableBuilder(
        valueListenable: currentUser,
        builder: (context, user, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 10, 28, PageScaffold.menuClearance),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: ProfileAvatar(onEdit: edit)),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: edit,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.username,
                          style: AppText.poppins(20, color: context.headingColor, weight: FontWeight.w600).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: context.headingColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 18, color: context.headingColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const ProfileLabel('Nome Completo'),
                ProfileField(text: user.displayName),
                const ProfileLabel('Email'),
                ProfileField(text: user.email),
                const ProfileLabel('Senha'),
                const ProfileField(text: '**************', showEye: true),
                const SizedBox(height: 40),
                const Center(child: LbLogo(height: 90, wordmark: true, opacity: 0.35)),
              ],
            ),
          );
        },
      ),
    );
  }
}
