import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';
import 'catalogue.dart';

Future<void> main() async {
  final books = rawBooks.map(Book.fromJson).toList();
  final library = Library(books);
  library.open();

  await Future.delayed(Duration(seconds: 3));

  print('Titles: ${library.titles.join(', ')}');
  print('');
  print('Country of Clean Code: ${library.countryOf('Clean Code')}');
  print('');
  print('Report: ${library.report}');
  print('');
  print('Books after 2010: ${library.booksAfter2010.join(', ')}');
  print('');
  print('Average pages: ${library.averagePages}');
  print('');
  print('Books by author:');
  library.booksByAuthor.forEach((k, v) => print('$k - $v'));
  print('');
  print('Authors: ${library.authorNames.join(', ')}');
  print('');
  print('Genres: ${library.genres.join(', ')}');
  print('');
  print('Display: ${library.displayLines.join('\n')}');
  print('');

  final stats = statsOf(books);
  print('Stats: count=${stats.count}, average pages=${stats.avgPages}');
  print('');

  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('missing shelf label')));
}
