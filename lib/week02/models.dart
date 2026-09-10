class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => '$name, ${country ?? ''}';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;

  const Genre(this.label);

  static Genre fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'craft':
        return Genre.craft;
      case 'theory':
        return Genre.theory;
      default:
        return Genre.unknown;
    }
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow: $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  const Book.missing()
    : pages = 0,
      author = const Author(name: 'Unknown'),
      genre = Genre.unknown,
      description = null,
      super(title: 'Unknown', year: 0);

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: _stringValue(json['title']) ?? 'Unknown',
      year: _intValue(json['year']) ?? 0,
      pages: _intValue(json['pages']) ?? 0,
      author: Author(
        name: _stringValue(json['author']) ?? 'Unknown',
        country: _stringValue(json['country']),
      ),
      genre: Genre.fromString(_stringValue(json['genre'])),
      description: _stringValue(json['description']),
    );
  }

  bool get isLong => pages > 400;

  @override
  String describe() {
    return '$title, $author, $year, $pages pages, ${genre.label}';
  }

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => '$title ($year, ${author.name})';

  static String? _stringValue(Object? value) => value is String ? value : null;

  static int? _intValue(Object? value) => value is int ? value : null;
}

class Magazine extends LibraryItem {
  final String issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() {
    return '$title, $year, Issue: $issue';
  }
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  String describe() => '$title ($year)';

  @override
  bool get isOld => year < 2000;
}
