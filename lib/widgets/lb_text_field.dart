import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Campo arredondado do protótipo.
/// - Padrão: fundo azul claro com ícone (telas de login/cadastro).
/// - `dark: true`: fundo azul-ardósia com texto branco (perfil e busca).
class LbTextField extends StatefulWidget {
  const LbTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon,
    this.isPassword = false,
    this.dark = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.trailing,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool isPassword;
  final bool dark;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// Widget no fim do campo (ex.: lupa da busca).
  final Widget? trailing;

  @override
  State<LbTextField> createState() => _LbTextFieldState();
}

class _LbTextFieldState extends State<LbTextField> {
  late bool _hidden = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final fill = widget.dark ? AppColors.slate : AppColors.inputFill;
    final fg = widget.dark ? Colors.white : AppColors.navy;

    Widget? suffix = widget.trailing;
    if (widget.isPassword) {
      suffix = IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility, color: fg),
      );
    }

    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      cursorColor: fg,
      style: AppText.poppins(16, color: fg),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: widget.hint,
        hintStyle: AppText.poppins(16, color: fg.withValues(alpha: 0.85)),
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: fg, size: 26),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
