
import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../data/reading_repository.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/book_card.dart';
import '../widgets/book_tile.dart';
import '../widgets/lb_app_bar.dart';
import '../widgets/page_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: const LbAppBar(),
      drawer: const AppDrawer(),
      menuIndex: 1,
      child: ValueListenableBuilder<int>(
        valueListenable: ReadingRepository.revision,
        builder: (_, __, ___) => FutureBuilder<List<Book>>(
          future: bookRepository.getBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Não foi possível carregar as obras.',
                  style: AppText.poppins(15, color: context.headingColor),
                ),
              );
            }

            final books = snapshot.data ?? const <Book>[];
            final reading = books.where((b) => b.started && !b.finished).toList();
            final highlight = reading.isNotEmpty ? reading.first : (books.isNotEmpty ? books.first : null);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverList.list(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 10),
                        child: Text('Continue a ler . . .', style: AppText.playfair(24, color: context.headingColor)),
                      ),
                      if (highlight != null) BookTile(book: highlight),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
