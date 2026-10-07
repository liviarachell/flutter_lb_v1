import 'package:flutter/material.dart';

import '../models/book.dart';
import '../pages/leitor_page.dart';
import '../theme/app_theme.dart';
import 'book_cover.dart';
import 'gradient_button.dart';
import 'lb_progress_bar.dart';

/// Ação do botão "Continuar". Troque pelo leitor de livros quando existir.
void openBook(BuildContext context, Book book) {
  if (book.contentUrl == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Esta obra ainda não possui conteúdo de leitura.')));
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LeitorPage(book: book)),
  );
}

/// Card de livro do protótipo: capa em cima, painel verde-oliva embaixo com
/// título, ano, dificuldade, progresso e botão.
class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, this.onContinue});

  final Book book;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: BookCover(book: book)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 98, 101, 136),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.playfair(15),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 104, 111, 196),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${book.year}', style: AppText.playfair(10)),
                      ),
                    ],
                  ),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.josefin(11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(book.difficulty, style: AppText.playfair(10, weight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progresso', style: AppText.playfair(10, weight: FontWeight.w400)),
                      Text('${book.percent}%', style: AppText.playfair(10, weight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  LbProgressBar(value: book.progress),
                  const SizedBox(height: 8),
                  GradientButton(
                    label: book.finished ? 'Ler novamente' : 'Continuar',
                    height: 28,
                    textStyle: AppText.poppins(11, weight: FontWeight.w700),
                    onPressed: onContinue ?? () => openBook(context, book),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grade de 2 colunas com os cards (para usar dentro de CustomScrollView).
class SliverBookGrid extends StatelessWidget {
  const SliverBookGrid({super.key, required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.64,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) => BookCard(book: books[i]),
    );
  }
}
