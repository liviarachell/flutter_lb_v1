
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_panel.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/lb_logo.dart';
import '../widgets/lb_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _error = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _email.text.trim().contains('@') && _password.text.isNotEmpty;
    setState(() => _error = !valid);
    if (!valid) return;

    setState(() => _loading = true);
    try {
      await authRepository.login(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 24),
              const LbLogo(height: 110),
              const SizedBox(height: 24),
              Expanded(
                child: AuthPanel(
                  title: 'Bem vindo(a)!',
                  children: [
                    LbTextField(
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    LbTextField(
                      hint: 'Senha',
                      icon: Icons.gpp_good_outlined,
                      controller: _password,
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
                                  'Email ou senha incorretos.',
                                  style: AppText.poppins(13),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: _loading ? 'Entrando...' : 'Entrar',
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text('Não possui conta?', style: AppText.poppins(14)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/cadastro'),
                          child: Text(
                            'Cadastre aqui!',
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
        ),
      ),
    );
  }
}
