**Mobile Development** **Practice 11: A Real Server**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**A Real Server**

Postman first → fromJson that survives → a repository with a timeout → the chain to the screen → two kinds of "no network"

In this lab the fake API from Practice 10 is replaced by a real one — `jsonplaceholder.typicode.com` — and nothing on the screen changes. You look at the real JSON before you write a line of Dart, write a model whose casts are claims you can defend, put every `http` call into one repository with a ten-second timeout and your own exceptions, and wire it to a `ChangeNotifier` and a screen that switches on a sealed class. Then you break the network two different ways and watch the app survive both.

**One sentence carries the whole lab:** the repository is the only class that knows `http` exists. Screens ask it for models and get models — or one of your exceptions. Never a `Response`, never a status code, never a `Map`. At the end `grep` proves it.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **Postman first** | GET by hand, the real JSON, nested objects, which fields are nullable |
| Level 2 | **A model that survives** | `fromJson` / `toJson`, `as num`, `as String?`, nested `fromJson`, `DateTime.parse` |
| Level 3 | **The repository** | `Uri.https`, `http.Client` injected, `_send` with `.timeout`, `_check`, `sealed class ApiException` |
| Level 4 | **The chain** | `ChangeNotifier` with `loading` / `error` / `items`, a `switch` on the sealed error, `Consumer`, Retry |
| Level 5 | **Two kinds of no network** | airplane mode vs. a dead Wi-Fi, `TimeoutException`, DevTools → Network, POST with `toJson` |
**Starter Code**

`flutter create users_api`, `flutter pub add http provider`. Copy this into `lib/core/api/api_exception.dart`. It is the three piles from the lecture as classes; the repository throws them and the screen switches on them. Everything else you write yourself in the feature-first tree the lecture showed: `lib/core/api/`, `lib/features/users/`.

`sealed class ApiException implements Exception {`

`  const ApiException();`

`}`

` `

`// no response at all: SocketException or a timeout`

`class NoConnectionException extends ApiException {`

`  const NoConnectionException();`

`}`

` `

`// their server: 5xx`

`class ServerException extends ApiException {`

`  const ServerException(this.status);`

`  final int status;`

`}`

` `

`// my request: 4xx`

`class NotFoundException extends ApiException {`

`  const NotFoundException();`

`}`

` `

`class UnauthorizedException extends ApiException {`

`  const UnauthorizedException();`

`}`

` `

`// JSON we could not read: a bug report, not a Retry`

`class BadResponseException extends ApiException {`

`  const BadResponseException([this.detail]);`

`  final String? detail;`

`}`

---

**Tasks (5)**

**1.** **Level 1: Postman first**

Nothing in Dart until you have seen the wire. In Postman (or `curl` in the terminal):

• `GET https://jsonplaceholder.typicode.com/users` and `GET …/users/1`. Look at the response: status, `Content-Type`, and the body. Write into `NOTES.md`: how many users, the exact key names, which values are nested objects (`address`, `company`), which are nested twice (`address.geo`), and which fields could be absent or null

• `GET …/users/999` — what status comes back, and what is in the body? `POST …/users` with a JSON body and `Content-Type: application/json` — what status, and what does the server add to what you sent? Write both down; Level 3 maps these statuses to exceptions

• Try `GET https://jsonplaceholder.typicode.com/users?id=3` — the query is how `Uri.https` will pass filters. Note the shape of the answer: a list of one, not an object

**The test of whether you did this right:**

• `NOTES.md` has a four-line table — field, JSON type, Dart type, nullable? — for every top-level field of a user, plus `address` and `company` as their own tables. If you cannot fill the "Dart type" column from the JSON alone, you are not ready to write `fromJson`; look again.

**2.** **Level 2: A model that survives bad JSON**

`lib/features/users/user.dart` — three classes, each with `fromJson` and `toJson`:

• `Geo(lat, lng)` — the server sends them as **strings** (`"-37.3159"`); your model stores `double`, so `fromJson` uses `double.parse(json['lat'] as String)`. `Address(street, suite, city, zipcode, geo)` with `geo: Geo.fromJson(json['geo'] as Map<String, dynamic>)`. `User(id, name, username, email, phone, website, address, company)` — `company` is a record `({String name, String catchPhrase})` built in `fromJson`

• Every cast is a claim: `json['id'] as int`, `json['name'] as String`. Make `website` a `String?` read with `as String?` — the only field you treat as optional — and `phone` normalised: keep the raw string, add a getter `phoneDigits` that strips everything but digits and `+` with a `RegExp`

• `toJson()` returns the same shape the server sent, nested maps included, so that `User.fromJson(user.toJson())` gives an equal user. Give `User` an `==` and `hashCode` on `id` only, or `@override toString()` — you will need one of them when you print

• `const` constructors, `final` fields, no `late`, no `!`

**The test of whether you did this right:**

• Paste the real JSON of user 1 from Postman into `main()` as a raw string (`r''' … '''`), `jsonDecode` it, call `User.fromJson`, `debugPrint` the user — before `runApp`, no screen. Then break it on purpose: change `lat` to `json['lat'] as double`. It throws at the cast: `type 'String' is not a subtype of type 'double'`. Read the message, read the column, put `parse` back. Change `id` in the pasted JSON to `"1"` (a string): the same kind of throw, on `id`. That is a good failure — it names the field; Level 3 turns it into `BadResponseException`.

**3.** **Level 3: The repository — the only class that knows http**

`lib/core/api/api_client.dart` and `lib/features/users/user_repository.dart`:

• `ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'})` takes an `http.Client` through the constructor. `Future<http.Response> _send(Future<http.Response> Function() call)`: `try { return await call().timeout(const Duration(seconds: 10)); } on SocketException { throw const NoConnectionException(); } on TimeoutException { throw const NoConnectionException(); }`. `void _check(http.Response r)`: 401 → `UnauthorizedException`, 404 → `NotFoundException`, `>= 500` → `ServerException(r.statusCode)`. `dynamic _decode(http.Response r)`: `jsonDecode` inside a `try` that turns `FormatException` into `BadResponseException`

• `UserRepository(this._api)`: `Future<List<User>> getAll()`, `Future<User> getById(int id)`, `Future<User> create(User draft)` (POST with `jsonEncode(draft.toJson())`, `Content-Type: application/json`, expect 201). Addresses are built with `Uri.https(host, '/users/$id')` — never string concatenation. A cast that throws inside `fromJson` is caught in the repository and rethrown as `BadResponseException('users/$id: $e')`

• Headers in one place: `{'Accept': 'application/json'}` from a getter on `ApiClient`. In debug only, `log('${r.request?.method} ${r.request?.url.path} → ${r.statusCode}', name: 'api')` after every response — `dart:developer`, not `print`

**The test of whether you did this right:**

• From `main()`, before `runApp`: `getAll()` prints 10 names; `getById(999)` throws `NotFoundException` — catch it with `on NotFoundException` and print "not found"; `create(...)` prints the id the server assigned (11). Then `grep -rn "package:http" lib/` prints exactly two files: `api_client.dart` and `user_repository.dart`. Anything else is a leak.

• Break it on purpose: make `_check` forget 404 and call `getById(999)`. Now `_decode` succeeds — the body is `{}` — and `fromJson` throws on `id`. The error is still yours (`BadResponseException`) but it points at the wrong cause. That is why status is checked before the body, every time. Put the 404 line back.

**4.** **Level 4: The chain — repository → model → screen**

`users_model.dart` and `users_screen.dart`; `main.dart` wires them once:

• `class UsersModel extends ChangeNotifier { UsersModel(this._repo); List<User> items = const []; ApiException? error; bool loading = false; Future<void> load() async {...} }` — `loading = true; error = null; notifyListeners();` then `try { items = await _repo.getAll(); } on ApiException catch (e) { error = e; } finally { loading = false; notifyListeners(); }`. No `mounted`, no `BuildContext`, no `http` — it is not a State and not a repository

• `main.dart`: `ChangeNotifierProvider(create: (_) => UsersModel(UserRepository(ApiClient(http.Client())))..load(), child: const App())` — the composition root; the only file that says `http.Client()`

• `UsersScreen`: `final m = context.watch<UsersModel>();` `if (m.loading) return const LoadingView();` then a `switch (m.error) { null => UserList(m.items), NoConnectionException() => Offline(onRetry: m.load), NotFoundException() || UnauthorizedException() => ..., ServerException(:final status) => ServerError(status, onRetry: m.load), BadResponseException() => const GenericError() }` — exhaustive, because `ApiException` is sealed; no `default`

• `UserList`: `ListView.separated`, a `ListTile` per user — name, email, the city from `address` as the subtitle; tapping opens `UserDetailScreen` that shows everything, with the phone and the website as taps that do nothing yet (Practice 12 gives them `url_launcher`). Pull-to-refresh with `RefreshIndicator(onRefresh: m.load)`

**The test of whether you did this right:**

• Ten users, two-second-ish load on a real network, pull to refresh reloads. Delete the `BadResponseException()` arm from the switch: it does not compile — "The type 'ApiException?' is not exhaustively matched". That is week 2's sealed class doing its job six weeks later. Put it back.

• Change the host to `jsonplaceholder.typicode.co` (a typo). `SocketException` → `NoConnectionException` → the Offline view with Retry, within a second. Fix the host; Retry loads the list without restarting the app.

**5.** **Level 5: Two kinds of "no network" — and the proof**

The test everybody skips, because it needs a real phone:

• **Airplane mode.** Run on a real phone or the emulator, turn airplane mode on, pull to refresh. The Offline view must appear within a second — the OS knows there is no route and `SocketException` is immediate

• **A Wi-Fi that leads nowhere.** Connect the phone to a hotspot whose internet is off (your laptop's hotspot with Wi-Fi disconnected, or a router with the cable out). Pull to refresh. Now packets leave and never return. Without the timeout the spinner would spin for minutes; with it the same Offline view appears in ten seconds. Time it with a clock and write the number into `NOTES.md`

• Open DevTools → Network while you do the second test. The row for `/users` has no status and ~10 000 ms. Screenshot it as `screenshot_timeout.png`. Then, with the network back, screenshot a `200` row with its response body opened — `screenshot_200.png`

• POST from the UI: a small "New user" form (name, username, email — the validators from week 7) whose Save calls `repo.create` through a method on `UsersModel`, inserts the returned user (with the server's id) at the top of the list, and pops. `BadResponseException` or a 5xx → a `SnackBar`, the form stays open. `flutter analyze` clean, `dart format .` run, `unawaited_futures` still on from last week

**The test of whether you did this right:**

• Both no-network tests show the same screen, one within a second and one within ten. `NOTES.md` has the two timings. The Save button is disabled while the request is in flight (the `bool` from Practice 10), and a double tap sends one request — DevTools → Network shows one `POST`, status 201.

**Tip:** When the screen is empty and DevTools shows `GET /users 200`, the bug is not the network — it answered. Walk the ladder after the wire: the body (is it a list or an object with a `data` key?), the decode (`print(jsonDecode(body).runtimeType)`), one `fromJson` on the first item alone, then the four states. Three usual suspects: an envelope you did not unwrap, a key spelled differently from your model, and an exception swallowed by an empty `catch`. Never write `catch (e) {}` — this week or ever.

**Requirements**

• `flutter run` shows ten users from `jsonplaceholder.typicode.com`; `flutter analyze` prints `No issues found!`; `dart format .` has been run

• `NOTES.md`: the field tables from Postman, the statuses for `/users/999` and `POST /users`, the two no-network timings

• `User`, `Address`, `Geo` with `const` constructors, `fromJson` / `toJson` round-trip, `double.parse` for `lat` / `lng`, `company` as a record, `website` nullable; no `!`, no `late`

• `ApiClient(http.Client)` with `_send` (10-second timeout, `SocketException` and `TimeoutException` → `NoConnectionException`), `_check` (401, 404, 5xx), `_decode` (`FormatException` → `BadResponseException`); `log()` in debug only

• `UserRepository` with `getAll`, `getById`, `create`; `Uri.https` everywhere; `grep -rn "package:http" lib/` lists only `api_client.dart` and `user_repository.dart`

• `UsersModel` owns `loading` / `error` / `items`, catches `on ApiException` only — no empty `catch`, no `BuildContext`, no `mounted`; wired once in `main.dart`

• The screen `watch`es the model and switches exhaustively on the sealed error; `RefreshIndicator`; Retry calls `load`; the form's Save is disabled while in flight

• `screenshot_timeout.png` (a DevTools row with no status at ~10 s) and `screenshot_200.png` (a 200 row with the body) are committed

**Useful Links**

1. **Fetch data from the internet (cookbook):** [docs.flutter.dev/cookbook/networking/fetch-data](https://docs.flutter.dev/cookbook/networking/fetch-data)

2. **package:http:** [pub.dev/packages/http](https://pub.dev/packages/http)

3. **JSON and serialization:** [docs.flutter.dev/data-and-backend/serialization/json](https://docs.flutter.dev/data-and-backend/serialization/json)

4. **JSONPlaceholder — the API used here:** [jsonplaceholder.typicode.com](https://jsonplaceholder.typicode.com)

5. **DevTools: Network view:** [docs.flutter.dev/tools/devtools/network](https://docs.flutter.dev/tools/devtools/network)

**GOOD LUCK!** :)
