
import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/reading_repository.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/book_card.dart';
import '../widgets/page_scaffold.dart';

class LeiturasPage extends StatelessWidget {
  const LeiturasPage({super.key});

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

            final books = (snapshot.data ?? const <Book>[]).where((b) => b.started).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 14, 20, 10),
                  sliver: SliverToBoxAdapter(
                    child: Text('Suas Leituras', style: AppText.playfair(26, color: context.headingColor)),
                  ),
                ),
                if (books.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 10, 20, 0),
                      child: Text(
                        'Você ainda não começou nenhuma leitura. Use a busca para encontrar novas obras.',
                        style: AppText.poppins(14, color: context.headingColor),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, PageScaffold.menuClearance),
                    sliver: SliverBookGrid(books: books),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
