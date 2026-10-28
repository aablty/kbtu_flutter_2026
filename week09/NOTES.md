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

## Level 4: scope

`Cart` stores quantities in a private map. `count` remains the number of
distinct books, while `total` multiplies each price by its quantity. The badge
uses `context.select<Cart, int>((cart) => cart.count)`, so quantity changes do
not rebuild it.

The rebuild counter result for three plus presses was:

- badge with `watch`: 3 rebuilds;
- badge with `select`: 0 rebuilds.

Removing a book with `select` rebuilds the badge once because its count changes.

## Level 5: where does it live?

- Cart: provided — shared by both routes and owned by `ChangeNotifierProvider`.
- Search text: ephemeral — it belongs to the Books screen's search field.
- Cart total expanded/collapsed state: ephemeral — it would belong to the Cart screen.
- Theme mode: provided — an app-wide setting should be available above both routes.

The Add SnackBar and Clear confirmation are widget decisions; `Cart` only
returns a boolean from `add` and performs the state mutation.

## Verification

`flutter analyze` reports `No issues found!`, and `flutter test` passes. Runtime
screenshots were not captured in this environment because no Flutter device
was available to `flutter devices`.
