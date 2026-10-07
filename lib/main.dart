import 'package:flutter/material.dart';

import 'pages/cadastro_page.dart';
import 'pages/editar_perfil_page.dart';
import 'pages/encontrar_page.dart';
import 'pages/home_page.dart';
import 'pages/leituras_page.dart';
import 'pages/login_page.dart';
import 'pages/perfil_page.dart';
import 'pages/progresso_page.dart';
import 'pages/splash_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(const LeBrasilApp());

class LeBrasilApp extends StatelessWidget {
  const LeBrasilApp({super.key});

  static final Map<String, WidgetBuilder> _routes = {
    '/': (_) => const SplashPage(),
    '/login': (_) => const LoginPage(),
    '/cadastro': (_) => const CadastroPage(),
    '/home': (_) => const HomePage(),
    '/perfil': (_) => const PerfilPage(),
    '/editar-perfil': (_) => const EditarPerfilPage(),
    '/progresso': (_) => const ProgressoPage(),
    '/leituras': (_) => const LeiturasPage(),
    '/encontrar': (_) => const EncontrarPage(),
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (_, mode, _) => MaterialApp(
        title: 'lêBrasil',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final builder = _routes[settings.name] ?? _routes['/']!;
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
            transitionDuration: const Duration(milliseconds: 220),
            reverseTransitionDuration: const Duration(milliseconds: 180),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
}
