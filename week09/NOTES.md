# Practice 9 notes

## Level 1: lifted state

The cart is owned by `Shell` above `MaterialApp`. The same list is passed to
both routes and mutations travel upward through callbacks.

Adding `total` touched two constructors in two files:

- `BooksScreen` in `lib/books_screen.dart`;
- `CartBadge` in `lib/cart_badge.dart`.

The owner computes the total and passes it through `BooksScreen`, `AppBar`, and
`CartBadge`.

With six books, one Add tap prints seven lines: one `BooksScreen build` line
and six `row ...` lines.
