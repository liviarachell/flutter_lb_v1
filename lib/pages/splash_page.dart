import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';
import '../widgets/lb_logo.dart';

/// Tela inicial com o logotipo; segue sozinha para o login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientBackground(
        child: Center(child: LbLogo(height: 130, wordmark: true)),
      ),
    );
  }
}
