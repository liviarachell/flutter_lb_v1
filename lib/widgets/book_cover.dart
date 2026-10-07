import 'package:flutter/material.dart';

import '../models/book.dart';

/// Capa do livro: usa a imagem da internet (banco), a local (assets) ou,
/// se nenhuma existir, a ilustração padrão do protótipo.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.fit = BoxFit.cover});

  final Book book;
  final BoxFit fit;

  static const _fallback = 'assets/images/card_bg.jpg';

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(_fallback, fit: fit, alignment: Alignment.topCenter);
    if (book.coverUrl != null) {
      return Image.network(
        book.coverUrl!,
        fit: fit,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (book.coverAsset != null) {
      return Image.asset(
        book.coverAsset!,
        fit: fit,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return fallback;
  }
}
