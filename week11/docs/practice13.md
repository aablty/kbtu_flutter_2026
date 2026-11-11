**Mobile Development** **Practice 13: Where Things Go**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**Where Things Go**

Feature-first, one move per commit → interfaces and fakes → five green tests → extract widgets → read a trace

In this lab nothing new appears on the screen. You take the users app from Practices 11–12 — which by now is a dozen files in `lib/` — and give every file a place, every model a seam you can test through, and every rule a test that would go red if it broke. You do it in small steps, each one run and committed, so that `git log` reads like a plan. At the end you read one real stack trace in thirty seconds and reproduce the bug it names in a test.

**One sentence carries the whole lab:** dependencies point down — screens watch models, models use repositories, repositories touch the world — and never up. A `grep` proves the line holds; a fake proves the model does not care which repository it got; a test proves the rule.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **Feature-first** | `lib/core/`, `lib/features/<name>/`, `test/` mirrors `lib/`, one move per commit, the `grep` rule |
| Level 2 | **Interfaces and fakes** | `abstract interface class`, `Http…` and `Fake…`, constructor injection, `main.dart` as the only composition root |
| Level 3 | **Five green tests** | `flutter test`, `group` / `test` / `expect`, arrange–act–assert, `MockClient` from `package:http/testing` |
| Level 4 | **Extract widgets** | `build()` under 60 lines, Extract Widget, `const` leaves, one widget test with `pumpWidget` |
| Level 5 | **Read a trace** | message → your first frame → the path, `<asynchronous suspension>`, `log()` not `print()`, a test that reproduces the bug |
**Starter Code**

No new code to copy — the starter is your own repository. This is the tree you are moving towards; `test/` mirrors `lib/`. Create the folders first, then move files one at a time with the IDE (Refactor → Move), which fixes every import for you.

`lib/`

`  main.dart                      // composition root: the only Http…`

`  core/`

`    api/api_client.dart          // http.Client, host, _send, _check, _decode`

`    api/api_exception.dart       // the sealed hierarchy`

`    storage/secure_store.dart`

`    env.dart                     // Practice 14`

`  features/`

`    users/`

`      user.dart                  // User, Address, Geo + fromJson / toJson`

`      user_repository.dart       // interface + HttpUserRepository`

`      users_cache.dart`

`      users_model.dart           // ChangeNotifier: loading / error / items`

`      users_screen.dart`

`      user_detail_screen.dart`

`      widgets/user_tile.dart`

`      widgets/offline_banner.dart`

`    auth/     auth_model.dart  login_screen.dart`

`    settings/ settings_model.dart  settings_screen.dart`

`    profile/  profile_screen.dart`

`test/`

`  features/users/user_test.dart`

`  features/users/users_model_test.dart`

`  features/users/user_repository_test.dart`

`  features/users/users_screen_test.dart`

`  fakes/fake_user_repository.dart`

---

**Tasks (5)**

**1.** **Level 1: Feature-first, one move per commit**

From a flat `lib/` to the tree above — without changing one line of behaviour:

• `flutter test` (there are no tests yet — it must still say so and exit cleanly) and `flutter analyze` before you start. Then one move at a time: Refactor → Move in the IDE, run the app, `git commit -m "move users_model to features/users"`. Ten to fifteen commits whose messages are the moves. No "fix", no "refactor 2"

• Rename as you go: `utils.dart` and `helpers.dart` do not exist at the end — their contents went to the feature that owns them or to `core/`. One class per file, the file named after the class in `snake_case`

• The layer rule in one command, saved as `tool/check_layers.sh` and run before every commit: `grep -rl "package:http" lib/ | grep -v -e core/api -e _repository.dart` must print nothing; `grep -rl "package:flutter/material" lib/ | grep -e _model.dart -e _repository.dart -e core/api` must print nothing

**The test of whether you did this right:**

• `git log --oneline` reads like the story of the refactor — a reviewer can tell what moved without opening a diff. Both greps print nothing. Break it on purpose: add `import 'package:http/http.dart' as http;` to `users_screen.dart`. It compiles; the app runs; the script prints the file. The compiler has no opinion about layers — the script does. Remove the import.

**2.** **Level 2: Interfaces and fakes — the model never says new**

Every repository behind a contract, a real and a fake implementation, and one place that chooses:

• `abstract interface class UserRepository { Future<UsersResult> getAll(); Future<User> getById(int id); Future<User> create(User draft); }`. The Practice 11 class becomes `HttpUserRepository implements UserRepository`. `FakeUserRepository implements UserRepository` in `test/fakes/` (and exported for a demo mode): `FakeUserRepository({this.fail = false, this.delay = Duration.zero})` — returns two users built in Dart, or throws `const NoConnectionException()` when `fail` is true

• `UsersModel(this._repo)` asks for the **interface**; it never constructs a repository. The same for `AuthModel(SecureStore)` and `SettingsModel(SharedPreferencesAsync)` — anything that touches the disk or the wire arrives through the constructor

• `main.dart` is the composition root: `ApiClient` → `HttpUserRepository(api)` → `UsersModel(repo)` → `MultiProvider`. One commented line next to the real one: `// final UserRepository repo = FakeUserRepository();` — Practice 14 turns it into a `--dart-define`

**The test of whether you did this right:**

• `grep -rn "HttpUserRepository(" lib/` prints exactly one line, in `main.dart`. Swap the comment: the app runs with no network, two users, instantly — a demo mode for the defence machine. Swap it back. Then try to write the test from the lecture's question 3 — "NoConnection sets error" — against the old version of the model that built its own repository (check it out from git history for a minute): the first line you cannot write is the arrange step. Write that sentence into `NOTES.md`.

**3.** **Level 3: Five green tests**

`flutter test` finds everything under `test/` that ends in `_test.dart`. Five tests, in this order:

• `user_test.dart` — two `fromJson` tests: the real JSON of user 1 pasted as a string parses into the right `name`, `address.city` and `address.geo.lat` (a `double`); and a copy of it with `"id": "1"` (a string) `throwsA(isA<TypeError>())` — the cast is a claim and the test says so

• `users_model_test.dart` — `load → items from the repository` with `FakeUserRepository()`: `items` has length 2, `loading` is false, `error` is null; and `load → NoConnection sets error` with `FakeUserRepository(fail: true)`: `error` `isA<NoConnectionException>()`, `loading` is false. Arrange, act, assert — three lines each

• `user_repository_test.dart` — `MockClient` from `package:http/testing`: a client that returns `http.Response('{"error":"gone"}', 404)` makes `getById(99)` `throwsA(isA<NotFoundException>())`; one more with status 500 → `ServerException`; one whose handler `throw`s `SocketException('down')` → `NoConnectionException`. The `MockClient` is why `ApiClient` takes an `http.Client` in its constructor

• A unit test never touches the network, the disk or the clock. If a test needs Wi-Fi, it is not a unit test; if it is red on Monday after passing on Sunday, you know why

**The test of whether you did this right:**

• `flutter test` prints `+5` (or more) and green, in under five seconds, with airplane mode on. Break it on purpose: in `UsersModel.load` replace `on ApiException catch (e) { error = e; }` with an empty `catch (e) {}`. One test goes red, and the failure names the test, the Expected and the Actual, and the line of the `expect`. Read it top-down once. Restore the model; green again; commit "test UsersModel".

**4.** **Level 4: Extract widgets, then one widget test**

No `build()` over 60 lines, and a test that pumps one screen:

• In `users_screen.dart` select the header, the filter row, the empty state and the error view one at a time → Refactor → Extract Widget. Each becomes a `const`-constructible `StatelessWidget` in `widgets/` with the data it needs as parameters — not a `_buildHeader()` method. Say why in `NOTES.md` in two lines: what a widget can do that a method cannot (be `const`, have its own rebuild scope, appear in DevTools, be tested)

• `users_screen_test.dart` — `testWidgets('shows the offline view and Retry', …)`: arrange a `UsersModel(FakeUserRepository(fail: true))`, `await model.load()`, `pumpWidget(MaterialApp(home: ChangeNotifierProvider.value(value: model, child: const UsersScreen())))`; `expect(find.text('No connection'), findsOneWidget)`; `tester.tap(find.text('Retry'))`, `pump()`, expect a `CircularProgressIndicator`

• `const` on every leaf the analyzer asks for; `prefer_const_constructors` is already on from week 3. Run the app with "Track widget rebuilds" once and look at the extracted widgets by name

**The test of whether you did this right:**

• Six green tests. No `build()` longer than 60 lines — check with your eyes or `awk`. The widget test runs without an emulator, in about a second. Break it on purpose: change the Retry label to "Try again" in the widget and run the tests — the widget test fails with `Expected: exactly one matching candidate, Actual: zero`. That is a test doing its job: the screen changed and something noticed. Change it back.

**5.** **Level 5: Read a trace in thirty seconds**

One real crash, read in the lecture's order, reproduced in a test, fixed:

• Plant it: in the `FakeUserRepository` (or in a copy of the real JSON) make one user's `lat` a number instead of a string — `"lat": -37.3159` — and run the app against that fake. It crashes in `fromJson`. Do **not** fix it yet

• Copy the full trace into `NOTES.md` and annotate three lines: **the message** (`type 'double' is not a subtype of type 'String' in type cast`), **your first frame** (`#0 Geo.fromJson (package:users_api/features/users/user.dart:LL:CC)` — the line **and the column**), and **the path** down to `UsersModel.load` with its `<asynchronous suspension>`. Then the data that went in: which field, which user

• Reproduce it in `user_test.dart` with that JSON: `expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()))` — red, on purpose, on your machine. Now decide the fix as the lecture did: the server broke the contract, so the repository maps the throw to `BadResponseException('users: lat is not a String')` and the screen shows the generic error, not a crash. Make the test assert the new behaviour at the repository level. Green

• Replace every `print` in `lib/` with `log(..., name: '…')` from `dart:developer` or `debugPrint`; add `avoid_print` to `analysis_options.yaml` if it is not already enforced. Run the quality checklist from the lecture and paste the output into `README.md`: `flutter analyze` (0 issues), `dart format .` (no diff), `flutter test` (the count), `tool/check_layers.sh` (nothing)

**The test of whether you did this right:**

• `NOTES.md` has the annotated trace with the column number and one sentence saying why `#0` was the right place to throw and the wrong place to fix. `flutter test` is green with at least seven tests. `README.md` ends with the four commands and their output. A classmate who clones the repository can run `flutter test` and see the same numbers — that is the whole point of the lab.

**Tip:** The defence question this week is not "does it work" but "show me the test that would fail if this rule broke". Every rule in a model deserves one: the total, the filter, the no-duplicates, the status-to-exception mapping. Write the test first when you can — three lines, red — and the code second. A bug you reproduced in a test is a bug you fixed once; a bug you fixed by reading is one you will meet again at the endterm.

**Requirements**

• `lib/core/` and `lib/features/<name>/`; `test/` mirrors `lib/`; no `utils.dart` or `helpers.dart`; one class per file; `git log --oneline` is a list of named moves

• `tool/check_layers.sh` exists and prints nothing: `package:http` only under `core/api` and `*_repository.dart`; `package:flutter/material` never in a model or a repository

• Every repository behind an `abstract interface class` with an `Http…` and a `Fake…`; every model takes its dependencies through the constructor; `HttpUserRepository(` appears once, in `main.dart`

• At least seven green tests in under ten seconds offline: two `fromJson` (a valid user, a wrong type), two `UsersModel` (items, `NoConnection`), two or three `MockClient` mappings (404, 500, `SocketException`), one `testWidgets` for the offline state and Retry

• No `build()` over 60 lines; header, filters, empty and error views are extracted `StatelessWidget`s, `const` where possible

• The planted `lat` bug: its trace annotated in `NOTES.md` (message, first frame with column, path), reproduced in a test, mapped to `BadResponseException` in the repository

• No `print()` in `lib/`; `log()` or `debugPrint` only; `avoid_print` enforced

• `README.md` ends with the output of `flutter analyze`, `dart format .`, `flutter test` and `tool/check_layers.sh`

**Useful Links**

1. **An introduction to unit testing (cookbook):** [docs.flutter.dev/cookbook/testing/unit/introduction](https://docs.flutter.dev/cookbook/testing/unit/introduction)

2. **Mock dependencies: package:http/testing:** [pub.dev/documentation/http/latest/testing/MockClient-class.html](https://pub.dev/documentation/http/latest/testing/MockClient-class.html)

3. **An introduction to widget testing:** [docs.flutter.dev/cookbook/testing/widget/introduction](https://docs.flutter.dev/cookbook/testing/widget/introduction)

4. **Simple app state management: architecture:** [docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture)

5. **dart:developer log():** [api.flutter.dev/flutter/dart-developer/log.html](https://api.flutter.dev/flutter/dart-developer/log.html)

**GOOD LUCK!** :)
