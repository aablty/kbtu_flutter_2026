**Mobile Development** **Practice 9: Put It High, Subscribe Low**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**Put It High, Subscribe Low**

Lift it up → A model with no widgets → The same app with provider → Scope: select and Consumer → Logic on the right side

In this lab you build the shop from the lecture — a Books screen with Add buttons, a badge on the cart icon, a Cart screen on another route — and you build it twice. First with state lifted into a widget above `MaterialApp`: parameters down, callbacks up, and you count what that costs. Then with a `Cart` that is a plain Dart `ChangeNotifier`, put in the tree once with `provider` and reached from anywhere with three verbs. The screens look identical both times; that is the point.

**One sentence carries the whole lab:** put it high, subscribe low. The value lives above every widget that needs it; each widget says "I depend on this" from where it stands, and only the widgets that asked are rebuilt. By Level 4 you will measure that with the rebuild counter, not take it on faith.

**Build Levels**

| **Level**        | **Topic**                      | **Key Widgets**                                                                                             |
| ---------------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| Level 1          | **Lift it up**                 | a `StatefulWidget` above `MaterialApp`, `routes`, parameters down, callbacks up, `setState` in the owner    |
| Level 2          | **A model with no widgets**    | `ChangeNotifier`, `notifyListeners`, a private list, `List.unmodifiable`, getters, a rule in one place      |
| Level 3          | **The same app with provider** | `flutter pub add provider`, `ChangeNotifierProvider`, `create`, `context.watch`, `context.read`, `Consumer` |
| Level 4          | **Scope**                      | `context.select`, `Consumer` with `child`, `const`, "Track widget rebuilds"                                 |
| Level 5          | **Logic on the right side**    | a `bool` from the model, `SnackBar` and `showDialog` in the widget, `NOTES.md`, `flutter analyze`           |
| **Starter Code** |

`flutter create shop`, then copy this into `lib/main.dart`. It is the whole file; the three widgets it mentions do not exist yet — Level 1 writes them. Each widget goes in its own file: `lib/books_screen.dart`, `lib/cart_screen.dart`, `lib/cart_badge.dart`. The `Book` class and the list move to `lib/models/book.dart` in Level 2.

```dart
import 'package:flutter/material.dart';
import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Book {
  const Book({
    required this.title,
    required this.author,
    required this.price,
  });
  final String title;
  final String author;
  final int price; // tenge
}

const books = [
  Book(title: 'Widgets All the Way Down',
      author: 'A. Nurmagambetova', price: 4200),
  Book(title: 'Null Safety for Humans',
      author: 'B. Seitkali', price: 3100),
  Book(title: 'Constraints Go Down, Sizes Go Up',
      author: 'C. Tashimova', price: 5600),
  Book(title: 'The Navigator Is a Stack',
      author: 'D. Alibekov', price: 2900),
  Book(title: 'Forms That Validate Themselves',
      author: 'E. Omarova', price: 3800),
  Book(title: 'Put It High, Subscribe Low',
      author: 'F. Kairatuly', price: 4700),
];

// Level 1: the owner of the cart. It sits ABOVE MaterialApp
// so that both routes can see the same list.
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];
  void _add(Book b) => setState(() => _cart.add(b));
  void _remove(Book b) => setState(() => _cart.remove(b));
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        ),
        routes: {
          '/': (_) => BooksScreen(cart: _cart, onAdd: _add),
          '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
        },
      );
}
```

---

**Tasks (5)**

**1.** **Level 1: Lift it up**

Three widgets, no package, the cart passed by hand. Make the starter run:

• `BooksScreen` — a `StatelessWidget` with `final List<Book> cart` and `final void Function(Book) onAdd`. A `ListView` of `ListTile`s: title, author as subtitle; `trailing` is the text **Added** when the book is already in the cart, otherwise an `OutlinedButton` "Add" that calls `onAdd(b)`. The `AppBar` has `actions: [CartBadge(count: cart.length)]`

• `CartBadge` — a `StatelessWidget` with `final int count`: an `IconButton` with a shopping-cart icon wrapped in a `Badge(label: Text('$count'))`; tapping it does `Navigator.of(context).pushNamed('/cart')`. The badge is five widgets below the owner: Shell → BooksScreen → AppBar → actions → CartBadge

• `CartScreen` — `final List<Book> items`, `final void Function(Book) onRemove`; a `ListView` with a close icon per row that calls `onRemove(b)`; under the list a `Text` with the total: `items.fold(0, (sum, b) => sum + b.price)`

• Then the designer asks for the total price in the badge too. Do it the honest way — a second parameter, `total`, from the owner all the way down — and write in `NOTES.md` how many constructors you touched and which files

**The test of whether you did this right:**

• Add two books: the badge says 2, the two buttons say Added. Open the cart, remove one, go back: the badge says 1 and the button is back. Both screens see the same list, and no screen owns it.

• Put `debugPrint('BooksScreen build')` at the top of `BooksScreen.build` and `debugPrint('row ${b.title}')` inside the `ListTile` loop. Tap Add once. Count the lines in the console. One tap rebuilt the whole screen and every row — `setState` in `Shell` marks everything under it dirty. Write the number into `NOTES.md`. Level 4 brings it down.

**2.** **Level 2: A model with no widgets**

Move the cart out of the widget tree into a class that could run without Flutter:

• `lib/models/book.dart` gets `Book` and `books`. `lib/models/cart.dart` gets `class Cart extends ChangeNotifier` (import `package:flutter/foundation.dart` — nothing from `material.dart`): a **private** `final List<Book> _items = []`; getters `List<Book> get items => List.unmodifiable(_items)`, `int get count`, `int get total` with `fold`; `bool add(Book b)` — returns `false` and does nothing when the book is already there, otherwise adds, calls `notifyListeners()`, returns `true`; `void remove(Book b)` and `void clear()`, both ending with `notifyListeners()`

• The rule "no duplicates" lives in `add` and nowhere else. Nothing in `Cart` mentions `BuildContext`, `SnackBar`, `Navigator`, a colour or a widget

• Prove it runs without a screen. In `main()`, **before** `runApp`: create a `Cart`, `add` two books, `add` the first one again, `remove` one, and `debugPrint('${cart.count} items, ${cart.total} ₸')`. Then delete those lines — Level 3 gives the Cart a proper home

**The test of whether you did this right:**

• The console prints `1 items, 3100 ₸` (or whichever book you kept) before the first frame — the model answered with no widget in sight. Then break it on purpose: write `cart.items.add(books[0])` in `main()`. It throws `Unsupported operation: Cannot add to an unmodifiable list`. Outside code cannot change the cart behind its back; only `add` can, and `add` always notifies.

• Now try to give `Cart` a `BuildContext` field "for later". The `main()` lines no longer compile — there is no context before `runApp`. That is the test from the lecture: if the model needs a context, it is doing a widget's job.

**3.** **Level 3: The same app with provider**

`flutter pub add provider`. Put the `Cart` in the tree once and delete every cart parameter:

• `main()` becomes `runApp(ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()))`. `Shell` becomes a `StatelessWidget` that only builds `MaterialApp` with the two routes — no list, no callbacks, no `setState`. `BooksScreen` and `CartScreen` lose their cart constructor parameters; `CartBadge` loses `count`

• The badge subscribes: `final n = context.watch<Cart>().count;` in `build`. The Add button calls without subscribing: `onPressed: () => context.read<Cart>().add(b)`. The **Added** / button decision in the row reads `context.watch<Cart>().items.contains(b)`

• `CartScreen` wraps its list in `Consumer<Cart>(builder: (context, cart, _) => ...)` — inside the builder you already hold `cart`, so the close icon is `onPressed: () => cart.remove(b)` with no verb at all

• `import 'package:provider/provider.dart'` in every file that uses a verb; the model file still imports only `foundation.dart`

**The test of whether you did this right:**

• Same app, same taps, same screens — and `grep -r "cart:" lib/` finds nothing. No widget between the provider and the badge knows the cart exists.

• Break it on purpose, both ways. Change the Add button to `context.watch<Cart>().add(b)`: tap it — provider throws "Tried to listen to a value exposed with provider, from outside of the widget tree" and names the fix. Put it back. Then change the badge to `context.read<Cart>().count`: no error, it compiles, it runs — and the badge is frozen at 0 forever, because nobody said "I depend on the cart". Put `watch` back. Write both error texts into `NOTES.md`: the loud one and the silent one.

**4.** **Level 4: Scope — select and Consumer**

Make a change that does not touch the count, and prove the badge does not rebuild:

• Quantities. In `Cart` replace the list with `final Map<Book, int> _qty = {}`: `items` is `_qty.keys.toList()`, `count` is `_qty.length` (distinct books), `int qtyOf(Book b)`, `void increment(Book b)` (+1 and notify), `total` multiplies price by quantity. `add` puts the book in with quantity 1; `remove` deletes the key. The row on the Cart screen shows `×2` and a plus icon that calls `increment`

• The badge rebuilds on every `notifyListeners` — including a quantity change that does not change its number. Switch it to `final n = context.select<Cart, int>((c) => c.count);`

• The total line on the Cart screen: a `Consumer<Cart>` whose `child` is a `const` widget that never changes (an icon with a label), passed through the builder with `child!` — built once, not on every notify

• Measure, do not believe. Keep `debugPrint('badge build')` in `CartBadge.build`, and open the rebuild counter: Android Studio → Flutter Performance → **Track widget rebuilds**, or DevTools → Performance → **Track widget builds**. Press + on a cart row three times with `watch` in the badge, then three times with `select`. Write both numbers into `NOTES.md`

**The test of whether you did this right:**

• With `watch`: three presses on + print `badge build` three times — the count did not change, the badge rebuilt anyway. With `select`: three presses print nothing; remove a book: it prints once. Same model, same taps, one line changed in one widget.

• Now move the `watch` up on purpose: put `context.watch<Cart>()` into `BooksScreen.build` and watch the row counter — every row rebuilds on every + in the cart, on another screen. Subscribe where the value is shown, not where it is convenient.

**5.** **Level 5: Logic on the right side of the line**

• Add shows a `SnackBar` "Added" — but the model must not know. `add` already returns a `bool`; the widget decides: `final ok = context.read<Cart>().add(b); if (ok) ScaffoldMessenger.of(context).showSnackBar(...)`. A second tap on the same book shows nothing: the model said no, quietly

• "Clear cart" in the Cart screen's `AppBar`: `showDialog<bool>` with an `AlertDialog` asking first (week 4), `context.mounted` after the `await`, and only on `true` — `context.read<Cart>().clear()`. The question lives in the widget; the clearing lives in the model

• `NOTES.md` gets one more section, **Where does it live?** — four values, one line each, with the home from the lecture (ephemeral · lifted · provided) and why: the cart; the search text in a search field you add to the Books `AppBar` that filters the list; whether the Cart screen's total is expanded or collapsed; the theme mode if there were a dark-mode switch

• `flutter analyze` prints `No issues found!`; `dart format .` has been run; `cart.dart` imports only `foundation.dart`; `screenshot_books.png` (two books added, the badge showing 2) and `screenshot_cart.png` (a quantity of 2 and the total) are committed

**Tip:** The mistake that costs the most time this week is silent: `context.read` inside `build`. Nothing is red, the app runs, and a number on the screen simply never changes again. When a widget "does not update", check the verb before anything else: `watch` is a verb of `build`, `read` is a verb of `onPressed`. Inside a `Consumer` builder you need neither — the object is already in your hand.

**Requirements**

• `flutter run` shows the Books screen and `flutter analyze` prints `No issues found!`

• Level 1 is kept in git history (a commit named `lifted`) — the final app uses provider; `NOTES.md` has the constructor count from Level 1

• `lib/models/cart.dart`: `Cart extends ChangeNotifier`, a private map, `items` unmodifiable, `count`, `total`, `qtyOf`, `bool add`, `remove`, `increment`, `clear` — every mutation ends with `notifyListeners()`; the file imports only `foundation.dart`

• `ChangeNotifierProvider(create: ...)` above `MaterialApp`; no `.value` with a new object in `build`; no cart parameter in any constructor

• `watch` only inside `build`, `read` only inside callbacks, `Consumer` around the Cart list; the badge uses `select` on `count`

• `NOTES.md`: the rebuild counts for the badge with `watch` and with `select`, both provider error texts from Level 3, and the **Where does it live?** section

• The Added `SnackBar` and the Clear dialog are decided in widgets from a `bool` the model returned; no `BuildContext`, `SnackBar` or `Navigator` anywhere in `models/`

• `dart format .` has been run; `screenshot_books.png` and `screenshot_cart.png` are committed

**Useful Links**

1. **Simple app state management (the provider guide):** [docs.flutter.dev/data-and-backend/state-mgmt/simple](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

2. **provider on pub.dev:** [pub.dev/packages/provider](https://pub.dev/packages/provider)

3. **ChangeNotifier:** [api.flutter.dev/flutter/foundation/ChangeNotifier-class.html](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)

4. **InheritedWidget:** [api.flutter.dev/flutter/widgets/InheritedWidget-class.html](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)

5. **Track widget rebuilds (DevTools):** [docs.flutter.dev/tools/devtools/performance](https://docs.flutter.dev/tools/devtools/performance)

**GOOD LUCK!** :)
