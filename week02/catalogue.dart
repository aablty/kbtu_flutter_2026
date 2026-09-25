import 'models.dart';

class Library {
  final List<LibraryItem> items;
  late final DateTime openedAt;
  bool _hasOpened = false;
  String? _cachedReport;

  Library([List<LibraryItem>? initialItems])
    : items = initialItems ?? <LibraryItem>[];

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    final fn = (Book? found, Book book) {
      return found ?? (book.title == title ? book : null);
    };
    return _books.fold<Book?>(null, fn);
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  void open() {
    if (_hasOpened) return;
    openedAt = DateTime.now();
    _hasOpened = true;
  }

  String? get report => _cachedReport ??= _buildReport();

  Iterable<Book> get _books => items.whereType<Book>();

  String? _buildReport() {
    final opened = _hasOpened ? openedAt : null;
    if (opened == null) return null;

    final now = DateTime.now();
    final duration = now.difference(opened);
    return 'Library has been open for ${duration.inHours} hours and '
        '${duration.inMinutes % 60} minutes.';
  }

  List<String> get titles {
    return items.map((item) => item.title).toList();
  }

  List<Book> get booksAfter2010 {
    return _books.where((book) => book.year > 2010).toList();
  }

  // reduce cant calculate an average for an empty collection.
  double get averagePages {
    if (_books.isEmpty) return 0.0;
    final fn = (int total, Book book) => total + book.pages;
    return _books.fold<int>(0, fn) / _books.length;
  }

  Map<String, int> get booksByAuthor {
    final fn = (Map<String, int> map, Book book) {
      map[book.author.name] = (map[book.author.name] ?? 0) + 1;
      return map;
    };
    return _books.fold<Map<String, int>>({}, fn);
  }

  Set<String> get authorNames => _books.map((book) => book.author.name).toSet();

  Set<Genre> get genres => _books.map((book) => book.genre).toSet();

  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in _books) '${book.title} (${book.year})',
    ..._books.map((book) => book.author.name),
    if (_books.any((book) => book.pages == 0)) '(incomplete data)',
  ];
}
