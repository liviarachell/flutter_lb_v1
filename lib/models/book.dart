
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.difficulty,
    required this.progress,
    this.coverAsset,
    this.coverUrl,
    this.contentUrl,
  });

  final String id;
  final String title;
  final String author;
  final int year;
  final String difficulty;

  /// Progresso de leitura de 0.0 a 1.0.
  final double progress;

  final String? coverAsset;
  final String? coverUrl;

  /// Página/texto público usado pelo leitor interno.
  final String? contentUrl;


  Book copyWith({
    double? progress,
    String? coverAsset,
    String? coverUrl,
    String? contentUrl,
  }) =>
      Book(
        id: id,
        title: title,
        author: author,
        year: year,
        difficulty: difficulty,
        progress: progress ?? this.progress,
        coverAsset: coverAsset ?? this.coverAsset,
        coverUrl: coverUrl ?? this.coverUrl,
        contentUrl: contentUrl ?? this.contentUrl,
      );

  bool get started => progress > 0;
  bool get finished => progress >= 1;
  int get percent => (progress * 100).round();

  factory Book.fromMap(Map<String, dynamic> map) => Book(
        id: map['id'].toString(),
        title: map['title'] as String,
        author: map['author'] as String,
        year: (map['year'] as num).toInt(),
        difficulty: (map['difficulty'] as String?) ?? 'Fácil',
        progress: ((map['progress'] as num?) ?? 0).toDouble(),
        coverUrl: map['cover_url'] as String?,
        contentUrl: map['content_url'] as String?,
      );
}
