import 'package:flutter/material.dart';

import '../data/book_repository.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/book_card.dart';
import '../widgets/lb_logo.dart';
import '../widgets/lb_text_field.dart';
import '../widgets/page_scaffold.dart';

/// Busca de obras: campo "Encontre mais. . ." e resultados em "Aqui está".
class EncontrarPage extends StatefulWidget {
  const EncontrarPage({super.key});

  @override
  State<EncontrarPage> createState() => _EncontrarPageState();
}

class _EncontrarPageState extends State<EncontrarPage> {
  final _controller = TextEditingController();
  List<Book> _results = const [];
  bool _searched = false;
  int _requestId = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    if (query.trim().isEmpty) {
      setState(() {
        _results = const [];
        _searched = false;
      });
      return;
    }
    final found = await bookRepository.search(query);
    if (!mounted || id != _requestId) return; // ignora respostas antigas
    setState(() {
      _results = found;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.headingColor;

    Widget body;
    if (!_searched) {
      body = const Center(child: LbLogo(height: 190, opacity: 0.45));
    } else if (_results.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Nenhuma obra encontrada. Tente outro título ou autor.',
            textAlign: TextAlign.center,
            style: AppText.poppins(14, color: color),
          ),
        ),
      );
    } else {
      body = CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(32, 10, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text('Aqui está', style: AppText.gelasio(20, color: color, weight: FontWeight.w700)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, PageScaffold.menuClearance),
            sliver: SliverBookGrid(books: _results),
          ),
        ],
      );
    }

    return PageScaffold(
      menuIndex: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
            child: LbTextField(
              hint: 'Encontre mais. . .',
              dark: true,
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _search,
              onSubmitted: _search,
              trailing: const Icon(Icons.search, color: Colors.white, size: 28),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
