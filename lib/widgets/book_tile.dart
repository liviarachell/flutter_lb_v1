import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_theme.dart';
import 'book_card.dart';
import 'book_cover.dart';
import 'lb_progress_bar.dart';

/// Bloco largo azul (o retângulo arredondado do protótipo) com a miniatura
/// da capa, título, autor e progresso. Usado em "Continue a ler" e "Seu Progresso".
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openBook(context, book),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.tileBlue.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 62, height: 92, child: BookCover(book: book)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.playfair(18)),
                  Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.josefin(13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(book.finished ? 'Concluído' : 'Progresso',
                          style: AppText.playfair(11, weight: FontWeight.w400)),
                      Text('${book.percent}%', style: AppText.playfair(11, weight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LbProgressBar(value: book.progress, height: 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
