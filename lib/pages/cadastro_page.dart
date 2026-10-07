
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_panel.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/lb_logo.dart';
import '../widgets/lb_text_field.dart';
import '../widgets/round_back_button.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _error = false;
  bool _loading = false;

  @override
  void dispose() {
    _user.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _user.text.trim().isNotEmpty &&
        _email.text.contains('@') &&
        _password.text.length >= 6 &&
        _password.text == _confirm.text;
    setState(() => _error = !valid);
    if (!valid) return;

    setState(() => _loading = true);
    try {
      await authRepository.register(
        username: _user.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 16,
                child: RoundBackButton(onPressed: _back),
              ),
              Column(
                children: [
                  const SizedBox(height: 16),
                  const LbLogo(height: 90),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AuthPanel(
                      title: 'Faça seu cadastro!',
                      children: [
                        LbTextField(
                          hint: 'Usuario',
                          icon: Icons.person,
                          controller: _user,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        LbTextField(
                          hint: 'Email',
                          icon: Icons.mail_outline,
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        LbTextField(
                          hint: 'Senha',
                          icon: Icons.gpp_good_outlined,
                          controller: _password,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        LbTextField(
                          hint: 'Confirme sua Senha',
                          icon: Icons.gpp_good_outlined,
                          controller: _confirm,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),
                        SizedBox(
                          height: 30,
                          child: _error
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 22),
                                    child: Text(
                                      'Confira se os dados estão corretos',
                                      style: AppText.poppins(13),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        GradientButton(
                          label: _loading ? 'Cadastrando...' : 'Cadastrar',
                          onPressed: _loading ? null : _submit,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text('Já possui cadastro?', style: AppText.poppins(14)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                              child: Text(
                                'Entrar aqui!',
                                style: AppText.poppins(14, weight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
