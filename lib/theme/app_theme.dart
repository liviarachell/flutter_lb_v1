import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta extraída do protótipo (flutter_lb.pdf).
class AppColors {
  AppColors._();

  static const skyTop = Color(0xFFB6E0FF);
  static const skyBottom = Color(0xFF5D9FF6);
  static const darkTop = Color(0xFF0A1633);
  static const darkBottom = Color(0xFF1B3B78);

  static const navy = Color(0xFF0D2353);
  static const wordmark = Color(0xFF0F2557);
  static const slate = Color(0xFF24324E);
  static const inputFill = Color(0xFFB8E1FF);

  static const buttonStart = Color(0xFF288EDA);
  static const buttonEnd = Color(0xFF579CF4);
  static const dialogButton = Color(0xFF14347A);

  static const cardOlive = Color(0xFFAFB75D);
  static const badgeOlive = Color(0xFFA9A017);
  static const tileBlue = Color(0xFF5B92D4);

  static const progressStart = Color(0xFFC8FAD8);
  static const progressEnd = Color(0xFF8CA8F0);
}

/// Fontes do protótipo: Playfair Display (títulos), Poppins (campos/botões),
/// Asap (logotipo), Gelasio (menu, no lugar da Cooper BT) e
/// Josefin Sans (textos dos cards, no lugar da Glacial Indifference).
class AppText {
  AppText._();

  static TextStyle playfair(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(fontSize: size, color: color, fontWeight: weight);

  static TextStyle poppins(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight);

  static TextStyle gelasio(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.gelasio(fontSize: size, color: color, fontWeight: weight);

  static TextStyle josefin(double size, {Color color = Colors.white, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.josefinSans(fontSize: size, color: color, fontWeight: weight);

  static TextStyle asap(double size, {Color color = AppColors.wordmark}) =>
      GoogleFonts.asap(fontSize: size, color: color, fontWeight: FontWeight.w600);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final base = ThemeData(brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: brightness),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.navy),
    );
  }
}

/// Controla o modo claro/escuro (botão lua/sol do menu lateral).
final ValueNotifier<ThemeMode> themeController = ValueNotifier(ThemeMode.light);

extension AppContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Cor dos títulos que ficam direto sobre o degradê.
  Color get headingColor => isDark ? const Color(0xFFDCEBFF) : AppColors.navy;
}
