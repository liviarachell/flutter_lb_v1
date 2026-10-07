import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/lb_logo.dart';
import '../widgets/lb_text_field.dart';
import '../widgets/page_scaffold.dart';
import 'perfil_page.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late final _name = TextEditingController(text: currentUser.value.displayName);
  late final _email = TextEditingController(text: currentUser.value.email);
  final _password = TextEditingController();

  bool get _dirty =>
      _name.text.trim() != currentUser.value.displayName ||
      _email.text.trim() != currentUser.value.email ||
      _password.text.isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres.')));
      return;
    }

    await authRepository.updateProfile(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );

    _password.clear();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Nova senha salva com sucesso.')));
  }

  Future<void> _save() async {
    await authRepository.updateProfile(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text.isEmpty ? null : _password.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Alterações salvas')));
    Navigator.of(context).pop();
  }

  /// Mostra "Deseja salvar alterações feitas?".
  /// [leaveOnCancel]: se true, "Cancelar" descarta as mudanças e sai da tela.
  Future<void> _confirm({required bool leaveOnCancel}) async {
    final save = await showDialog<bool>(
      context: context,
      builder: (_) => const _SaveDialog(),
    );
    if (!mounted) return;
    if (save == true) {
      await _save();
    } else if (leaveOnCancel) {
      Navigator.of(context).pop();
    }
  }

  void _onBack() {
    if (_dirty) {
      _confirm(leaveOnCancel: true);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      showBack: true,
      onBack: _onBack,
      menuIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, PageScaffold.menuClearance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ProfileAvatar()),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => _confirm(leaveOnCancel: false),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentUser.value.username,
                      style: AppText.poppins(20, color: context.headingColor, weight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, size: 22, color: context.headingColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const ProfileLabel('Nome Completo'),
            LbTextField(hint: 'Nome completo', dark: true, controller: _name),
            const ProfileLabel('Email'),
            LbTextField(
              hint: 'Email',
              dark: true,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const ProfileLabel('Senha'),
            LbTextField(
              hint: 'Nova senha',
              dark: true,
              isPassword: true,
              controller: _password,
              onChanged: (_) => setState(() {}),
            ),
            if (_password.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _savePassword,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Salvar nova senha'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dialogButton,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            const Center(child: LbLogo(height: 90, wordmark: true, opacity: 0.35)),
          ],
        ),
      ),
    );
  }
}

class _SaveDialog extends StatelessWidget {
  const _SaveDialog();

  @override
  Widget build(BuildContext context) {
    Widget button(String label, bool value) => SizedBox(
          width: 220,
          height: 44,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dialogButton,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.of(context).pop(value),
            child: Text(label, style: AppText.poppins(14, weight: FontWeight.w700)),
          ),
        );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deseja salvar alterações feitas?',
              textAlign: TextAlign.center,
              style: AppText.gelasio(18, color: AppColors.navy, weight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            button('Salvar alterações', true),
            const SizedBox(height: 10),
            button('Cancelar', false),
          ],
        ),
      ),
    );
  }
}
