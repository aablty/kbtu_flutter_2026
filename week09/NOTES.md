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

## Level 3: provider

`Cart` is created once by `ChangeNotifierProvider` above `MaterialApp`. The
screens have no cart parameters or callbacks. `watch` is used for displayed
values, `read` is used only in the Add callback, and `Consumer<Cart>` owns the
cart list on the Cart screen.

The two intentional provider mistakes were recorded as:

- loud error: `Tried to listen to a value exposed with provider, from outside
  of the widget tree`;
- silent error: using `context.read<Cart>().count` in the badge leaves it at
  its initial value because it does not subscribe.
