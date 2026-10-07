
import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/reading_repository.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/book_tile.dart';
import '../widgets/page_scaffold.dart';

class ProgressoPage extends StatelessWidget {
  const ProgressoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      showBack: true,
      menuIndex: 0,
      child: ValueListenableBuilder<int>(
        valueListenable: ReadingRepository.revision,
        builder: (_, __, ___) => FutureBuilder<List<Book>>(
          future: bookRepository.getBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data ?? const <Book>[];
            final reading = books.where((b) => b.started && !b.finished).toList();
            final done = books.where((b) => b.finished).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, PageScaffold.menuClearance),
              children: [
                const _Heading('Continue a ler . . .'),
                if (reading.isEmpty) const _Empty('Você não tem leituras em andamento.'),
                for (final b in reading) ...[BookTile(book: b), const SizedBox(height: 14)],
                const SizedBox(height: 22),
                const _Heading('Leituras Concluídas'),
                if (done.isEmpty) const _Empty('Nenhuma leitura concluída ainda.'),
                for (final b in done) ...[BookTile(book: b), const SizedBox(height: 14)],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 10),
        child: Text(text, style: AppText.playfair(24, color: context.headingColor)),
      );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Text(text, style: AppText.poppins(14, color: context.headingColor)),
      );
}
