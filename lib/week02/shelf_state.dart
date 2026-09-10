import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;

  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;

  Broken(this.message);
}

String describe(ShelfState state) {
  return switch (state) {
    Empty() => 'The shelf is empty.',
    Ready(:final books) => 'The shelf has ${books.length} books.',
    Broken(:final message) => 'The shelf is broken: $message',
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  final count = books.length;
  final fn = (int total, Book book) => total + book.pages;
  final avgPages = count == 0 ? 0.0 : books.fold<int>(0, fn) / count;
  return (count: count, avgPages: avgPages);
}
