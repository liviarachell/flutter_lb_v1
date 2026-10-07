
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class BookContentService {
  static Future<String> load(String url, String title) async {
    final response = await http.get(
      Uri.parse(url),
      headers: const {'User-Agent': 'leBrasil/1.0 (educational reader)'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível carregar a obra (${response.statusCode}).');
    }

    final document = html_parser.parse(response.body);
    final nodes = document.querySelectorAll('h1,h2,h3,h4,h5,p');
    var text = nodes
        .map((node) => node.text.trim())
        .where((value) => value.isNotEmpty)
        .join('\n\n');

    text = _removeBoilerplate(text);
    text = _startAtBook(title, text);

    if (text.trim().isEmpty) {
      throw Exception('O conteúdo desta obra não foi encontrado.');
    }

    return text;
  }

  static String _removeBoilerplate(String value) {
    var text = value
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ');

    // Evita que o leitor fique com a navegação do site no meio do livro.
    final removeLines = <String>{
      'Read online now',
      'Download for free',
      'Plain Text',
      'EPUB3',
      'EPUB',
      'Kindle',
      'Other formats & older devices',
      'About this eBook',
    };

    final lines = text.split('\n\n').map((line) => line.trim()).where((line) {
      if (line.isEmpty) return false;
      if (removeLines.contains(line)) return false;
      if (line.startsWith('http://') || line.startsWith('https://')) return false;
      return true;
    });

    return lines.join('\n\n');
  }

  static String _startAtBook(String title, String text) {
    if (title == 'Vidas Secas') {
      final index = text.indexOf('MUDANÇA');
      return index >= 0 ? text.substring(index) : text;
    }

    // As edições do Gutenberg começam os capítulos com algarismos romanos.
    final lines = text.split('\n\n');
    final start = lines.indexWhere((line) {
      final normalized = line.trim();
      return normalized == 'I' || normalized == 'I.' || normalized == 'CAPÍTULO I';
    });

    if (start > 0) return lines.sublist(start).join('\n\n');
    return text;
  }
}
