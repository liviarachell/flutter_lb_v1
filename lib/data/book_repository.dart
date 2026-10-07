
import '../models/book.dart';
import 'reading_repository.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<List<Book>> search(String query);
}

class LocalBookRepository implements BookRepository {
  static const _books = <Book>[
    Book(
      id: '1',
      title: 'Dom Casmurro',
      author: 'Machado de Assis',
      year: 1899,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/dom_casmurro.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/55752/pg55752-images.html',
    ),
    Book(
      id: '2',
      title: 'Vidas Secas',
      author: 'Graciliano Ramos',
      year: 1938,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/vidas_secas.jpg',
      contentUrl: 'https://literaturaonline.com.br/livro/vidas-secas/',
    ),
    Book(
      id: '3',
      title: 'O Primo Basílio',
      author: 'Eça de Queirós',
      year: 1878,
      difficulty: 'Difícil',
      progress: 0,
      coverAsset: 'assets/images/covers/o_primo_basilio.jpg',
      contentUrl: 'https://www.gutenberg.org/files/42942/42942-h/42942-h.htm',
    ),
    Book(
      id: '4',
      title: 'O Cortiço',
      author: 'Aluísio Azevedo',
      year: 1890,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/o_cortico.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/69187/pg69187-images.html',
    ),
    Book(
      id: '5',
      title: 'Iracema',
      author: 'José de Alencar',
      year: 1865,
      difficulty: 'Fácil',
      progress: 0,
      coverAsset: 'assets/images/covers/iracema.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/67740/pg67740-images.html',
    ),
    Book(
      id: '6',
      title: 'O Guarani',
      author: 'José de Alencar',
      year: 1865,
      difficulty: 'Fácil',
      progress: 0,
      coverAsset: 'assets/images/covers/o_guarani.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/67724/pg67724-images.html',
    ),
    Book(
      id: '7',
      title: 'Memórias Póstumas de Brás Cubas',
      author: 'Machado de Assis',
      year: 1881,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/memorias_postumas_de_bras_cubas.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/55752/pg55752-images.html',
    ),
    Book(
      id: '8',
      title: 'Senhora',
      author: 'José de Alencar',
      year: 1875,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/senhora.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/67726/pg67726-images.html',
    ),
    Book(
      id: '9',
      title: 'A Moreninha',
      author: 'Joaquim Manuel de Macedo',
      year: 1844,
      difficulty: 'Fácil',
      progress: 0,
      coverAsset: 'assets/images/covers/a_moreninha.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/67728/pg67728-images.html',
    ),
    Book(
      id: '10',
      title: 'O Ateneu',
      author: 'Raul Pompeia',
      year: 1888,
      difficulty: 'Médio',
      progress: 0,
      coverAsset: 'assets/images/covers/o_ateneu.jpg',
      contentUrl: 'https://www.gutenberg.org/cache/epub/67730/pg67730-images.html',
    ),
  ];

  @override
  Future<List<Book>> getBooks() async {
    final books = <Book>[];
    for (final book in _books) {
      final saved = await ReadingRepository.getProgress(book.id);
      books.add(book.copyWith(progress: saved > 0 ? saved : book.progress));
    }
    return books;
  }

  @override
  Future<List<Book>> search(String query) async {
    final q = _normalize(query);
    if (q.isEmpty) return [];
    final books = await getBooks();
    return books.where((b) => _normalize('${b.title} ${b.author}').contains(q)).toList();
  }

  static String _normalize(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    var out = s.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }
}

final BookRepository bookRepository = LocalBookRepository();
