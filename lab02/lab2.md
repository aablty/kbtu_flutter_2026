**Mobile Development** **Lab 2: A Production-Ready REST API Client**

---

**Submission:** One GitHub repository per pair; defended in week 14 during the practice sessions (syllabus: SIS, 5 points — marked individually).

**A Production-Ready REST API Client**

A real API → a repository that owns the wire → four states on every screen → storage that survives → tests, layers, a signed release

One app, built by two people, that talks to a real server and survives everything a real phone does to it: a restart, the metro, a 500, a user who says No. **The topic is yours; the shape is not** — every app in this lab has a catalogue that comes from a public API, a collection of your own with full create / read / update / delete, the same layers, the same four states, the same release checklist. It uses everything from weeks 9–14.

**How it is assessed** (syllabus): the repository is the admission ticket, the mark is for the defence. Each of you defends alone: you draw a task from the pool on the last page and change the code in 10 minutes, offline, without AI; you answer questions on the decisions in your own area and in your partner's; you find a defect the instructor plants. Code you cannot change or explain scores zero — for you, not for your partner. One re-defence within two weeks, capped at 75 %.

**Working in a pair.** Marks are individual, so the work must be visible as individual: every feature has one owner, every change goes through a pull request the other person reviews, and `git shortlog -sn` shows both of you. Section 4 is the contract; `TEAM.md` is where you sign it. Pairs are fixed by the end of week 12; after that, a pair that splits finishes as two individual Lab 2s with the same requirements.

**1. Pick an API and a domain**

Two resources. The **catalogue** comes from a public, read-only API. The **collection** is yours — things the user saves, rates or plans — and needs a server with full CRUD (section 2 says where to get one). Three combinations that fit — or bring your own, approved in the week-12 practice:

| **Catalogue (public API)** | **Collection (your CRUD backend)** | **The app** |
| --- | --- | --- |
| **REST Countries —** `restcountries.com` | trips: country, dates, budget, notes, rating | a travel planner |
| **TheMealDB —** `themealdb.com/api` | meal plans: recipe, day, servings, done | a weekly meal planner |
| **Open Library —** `openlibrary.org/dev/docs` | shelf entries: book, status, pages read, review | a reading tracker |
Not allowed: JSONPlaceholder as the only API (you used it in practice), an API without nested objects, a collection with fewer than six fields, two pairs with the same combination in the same group. Postman screenshots of both APIs go into `docs/` before any Dart is written.

**2. Where the backend comes from**

You do not write a server in this course. The catalogue is a public API; the collection lives on **any mock service or a local mock server** — the app cannot tell the difference, and that is the point of the repository. Pick one, write the choice and the base URL into `TEAM.md`, and keep the Postman screenshots of its responses in `docs/`.

| **Option** | **What it is** | **Good for** |
| --- | --- | --- |
| **A hosted mock service — MockAPI.io, Beeceptor, a Postman mock server, or any similar one** | you describe a resource in the browser and get an `https://` URL with real GET / POST / PUT / DELETE, real 404s, paging and search; data is kept on their side | the collection: works from the emulator and from a real phone with no setup; the same URL for both of you |
| **A local mock server — Mockoon (or** `json-server`**)** | a desktop app with CRUD routes over a data bucket, running on your laptop on a port; you decide the JSON, the status codes, the delays and the failures | the collection while developing; **simulating 500, timeouts and a slow network** on demand — which a hosted mock cannot do |
| **A public read-only API** | REST Countries, TheMealDB, Open Library, PokéAPI, dummyjson.com (which also has a real `/auth/login` with a JWT and `/products?limit=&skip=` paging) | the catalogue: nested objects, paging, search through the API's own query |
| **A real backend of your own (Supabase, a Dart** `shelf` **server, anything with HTTPS and JSON)** | allowed, not required, and not supported in class — the requirements are the same | a pair that already knows how; nothing in the mark depends on it |
Two things to know about a local server. From the Android emulator your laptop is `10.0.2.2`, not `localhost`; from a real phone it is the laptop's Wi-Fi address, and both must be on the same network. And both platforms block plain `http://` by default (lecture 11): for a local mock allow cleartext **for that host only, in the debug manifest only** (`android/app/src/debug/AndroidManifest.xml` with a network security config) — the release build keeps talking `https://` to the hosted service. The host is a `--dart-define` either way (Practice 14), never an edited file.

What the backend is **not** for: the defence. The defence machine has no network; the app is shown with `--dart-define=USE_FAKES=true` against your own `Fake…` repositories. The backend is for development, for the tests you run against a `MockClient`, and for the demo from your phone.

**3. The shape**

Seven screens behind one `MaterialApp`, three feature folders, one `core/`:

| **Screen** | **What it does** | **What it must show** |
| --- | --- | --- |
| **Login** | fake or real sign-in; token to secure storage | validation, a disabled button in flight, an error from the server |
| **Catalogue list** | search or filter against the public API; pull to refresh | loading · error with Retry · empty · data; a stale banner when offline |
| **Catalogue detail** | everything about one item; "Add to my collection" | nested objects rendered; a link opened with `url_launcher` |
| **My collection** | the user's items from your CRUD API | the same four states; swipe or menu to delete, asks first |
| **Item form** | create and edit, one screen | validators, a date picker, a dropdown; `PopScope` on a dirty form; returns the saved item |
| **Settings / profile** | dark mode, a filter default, a photo, sign out | settings that survive a restart; the camera permission flow |
| **About** | version, build mode, environment, licences | `1.0.x (N)`, `release`, the host — from `package_info_plus` and `Env` |
**4. Working in a pair**

`TEAM.md` in the repository root, written in week 12 and kept up to date:

| **Section** | **What it contains** | **Rule** |
| --- | --- | --- |
| **Owners** | a table: every feature folder, `core/api`, `core/storage`, tests, release — one **owner**, one **reviewer** | each person owns at least one feature end-to-end (model, repository, ChangeNotifier, screens, tests) and one shared area |
| **Workflow** | branches named `feature/<name>`, pull requests, who merges | nothing reaches `main` without a review by the other person; at least one comment per PR that changed something |
| **Contributions** | the output of `git shortlog -sn` pasted on the day of the defence | neither name below 35 % of commits; commits under your own name and email |
| **Decisions** | five to ten one-line decisions with the name of who made them | a decision you cannot name the owner of is one nobody can defend |
Two ways to split that both work — choose one in `TEAM.md`: **by feature** (A owns catalogue + `core/api`, B owns collection + auth + storage; settings and release shared) or **by layer with a twist** (A owns data and tests, B owns screens and state — and each still owns one full feature so both have touched every layer). A split where one person "does the UI" and never opens a repository fails the defence question on exceptions; a split where one person "does the backend" fails the one on `watch` vs `read`.

**5. Requirements**

One line each; numbered so the defence can point at them. All of them are checked; the owner column in `TEAM.md` says who answers for which.

**Team and process**

**R1** `TEAM.md` with the four sections above; owners cover every folder under `lib/` and `test/`; both names appear as owner of at least one feature.

**R2** Every change to `main` came through a pull request reviewed by the other person; the PR list is the history of the project.

**R3** `git shortlog -sn`: neither contributor below 35 %; commit messages name the change (`add offline cache for trips`), never `fix`, `wip`, `final`.

**R4** A `CHANGELOG.md` with at least two entries that match two GitHub Releases (R44).

**Data layer — core/api**

**R5** One `ApiClient(http.Client, {host, SecureStore})`: `Uri.https` everywhere, `_send` with a 10-second `timeout`, `SocketException` and `TimeoutException` → `NoConnectionException`, `_check` for 401 / 404 / 4xx / 5xx, `_decode` with `FormatException` → `BadResponseException`.

**R6** A `sealed class ApiException` with at least five subclasses; screens switch on it exhaustively — no `default`, no `catch (e) {}` anywhere in `lib/`.

**R7** One repository per resource behind an `abstract interface class`; an `Http…` and a `Fake…` for each; the fake is deterministic and can fail on demand.

**R8** The collection repository implements `getAll`, `getById`, `create`, `update`, `delete` against your CRUD backend (any mock service, or a local Mockoon / `json-server`) with the right methods, `Content-Type`, and status expectations (201 on create, 204 or 200 on delete); the backend and its base URL are named in `TEAM.md`.

**R9** The `Authorization: Bearer` header is added by `ApiClient` from secure storage; no repository and no screen ever sees the token.

**R10** `grep -rl "package:http" lib/` lists only `core/api/*` and `*_repository.dart`; `tool/check_layers.sh` is committed and prints nothing.

**R11** In debug, every request logs method, path, status and time with `log(name: 'api')`; nothing is logged in release; the token is never logged.

**R12** One request is cancelled or ignored correctly when the screen is left mid-flight: the console stays clean when you pop during a load.

**Models**

**R13** Every model is immutable (`final`, `const`, `copyWith`), with `fromJson` / `toJson` that round-trip; the catalogue model has a nested object parsed by its own `fromJson`.

**R14** Numbers are read as `num` and converted; nullable JSON is `T?` in Dart; a date is `DateTime.parse`d; no `!` in any `fromJson`.

**R15** A cast that fails inside `fromJson` becomes `BadResponseException` in the repository with the resource and field in its message.

**R16** At least one derived value lives in a model as a getter or a sealed state (progress, days left, status), never computed in `build`.

**State**

**R17** One `ChangeNotifier` per feature owning `loading` / `error` / `items` (or a sealed `Loaded` / `Failed`); it takes its repository through the constructor and contains no `BuildContext`, `mounted`, `SnackBar` or `Navigator`.

**R18** `watch` only in `build`, `read` only in callbacks, `select` on at least one small widget (a badge or a counter) with a comment saying why.

**R19** The composition root is `main.dart` and nothing else names an `Http…` class; `--dart-define=USE_FAKES=true` runs the whole app with no network.

**R20** Settings (dark mode, default filter) live in a `ChangeNotifier` backed by `shared_preferences`, read before `runApp` — no flash of the wrong theme.

**Screens**

**R21** Both lists show all four states — loading, error with Retry, empty with a sentence and an action, data — through one shared set of view widgets.

**R22** The catalogue list searches or filters through the API's own query, not by fetching everything; typing is debounced or submitted on Done; `RefreshIndicator` reloads.

**R23** The collection supports create, edit and delete from the UI; delete asks with `showDialog<bool>`; the list reflects the server's answer, not a local guess.

**R24** The item form: `Form` + validators beside the fields, controllers in `State` and disposed, a `DropdownButtonFormField`, a `readOnly` date field with `showDatePicker`, `autovalidateMode.onUserInteraction`, the keyboard handled (scroll, `next` / `done`, `onTapOutside`).

**R25** `PopScope` on the form: a dirty form asks, a clean one does not, Save never asks; the form returns the saved item through `pop` and the caller checks `null` and `mounted`.

**R26** Any button that starts a request is disabled while it is in flight and shows a small progress indicator; a double tap sends one request (DevTools proves it).

**R27** The catalogue list becomes a grid at 600 px through `LayoutBuilder`; the detail opens a link (`https:`) and, where the data has one, `mailto:` or `tel:` through `launchUrl` with the `bool` checked.

**R28** No `BackButton`, no `leading:`; route names are constants; the first screen depends on the stored token (login vs. catalogue).

**Storage and device**

**R29** The token lives in `flutter_secure_storage` only; sign out deletes it; the app opens signed in after a restart.

**R30** The catalogue repository caches the last good list in `getApplicationDocumentsDirectory()` and returns it on `NoConnectionException` with a flag; the screen shows a banner only then; with no cache the honest offline view appears.

**R31** A profile photo: `image_picker` behind `permission_handler`, requested at the tap, all statuses handled, `permanentlyDenied` → your dialog → `openAppSettings()`; declared in the manifest and `Info.plist`; Cancel → `null` handled.

**R32** The photo path and the settings survive a kill-and-reopen; nothing user-visible is stored in `getTemporaryDirectory()`.

**R33** Every package in `pubspec.yaml` has a one-sentence verdict in `docs/packages.md` (publisher, release date, platforms, points, dependencies); `pubspec.lock` is committed.

**Architecture and tests**

**R34** `lib/core/` and `lib/features/<name>/` only; `test/` mirrors `lib/`; one class per file; no `build()` over 60 lines; no `utils.dart`.

**R35** At least ten green tests, offline, in under ten seconds: `fromJson` with a valid object and a wrong type for each model; two rules per `ChangeNotifier` (data, `NoConnection`); `MockClient` mappings for 404, 500 and `SocketException`; one `testWidgets` per list for the error state and Retry.

**R36** A test exists for every rule you would name at the defence: if you say "an item cannot be added twice", there is a red-if-broken test for it.

**R37** `flutter analyze`: 0 issues with `flutter_lints`, `unawaited_futures`, `avoid_print`; `dart format .`: no diff; both outputs in the README.

**R38** No `print()`; `log()` from `dart:developer` or `debugPrint`; a planted crash's stack trace is annotated in `docs/trace.md` (message, first own frame with column, path).

**Release**

**R39** `applicationId` reverse-domain and yours; `minSdk` / `versionCode` / `versionName` from `flutter.*`; `version:` in pubspec bumped at least once (`1.0.1+2` or later).

**R40** A keystore you generated; `key.properties` and `*.jks` gitignored and never in history; the release signed with it (`keytool -printcert` output in `docs/`).

**R41** `lib/core/env.dart` is the only file with `fromEnvironment`; `env/prod.json`; the About screen shows version, mode, `Env.name` and `Env.host`; the developer host switch, if any, only behind `kDebugMode`.

**R42** Your icon (adaptive), your splash (Android 12), your app name; `INTERNET` in the main manifest; only the permissions you use, with iOS usage strings.

**R43** The release APK built with `--release --split-per-abi --obfuscate --split-debug-info`, symbols archived per version, installed from the file on a real phone over mobile data before the defence.

**R44** Two GitHub Releases (`v1.0.0`, then `v1.0.1` or later) with the arm64 APK attached; the fourteen-box pre-release checklist in the README, every box ticked with its proof.

**R45** `README.md`: what it is, two screenshots, the run lines including `USE_FAKES`, architecture in five lines, the test count, the team table, and a "Decisions" section of eight to twelve sentences with the owner's name after each.

**6. The defence pool**

One task is drawn at random per person — from your own area first; the instructor may add a second from your partner's. Ten minutes, your own code, offline, `USE_FAKES=true`.

• **1.** The server adds a new nullable field to the catalogue item — add it to the model, `fromJson`, `toJson`, the detail screen, and a test with it present and absent.

• **2.** Map one more status (429 Too Many Requests) to a new `ApiException` subclass and show a dedicated message with Retry; the switch must not compile until every screen handles it.

• **3.** Change the timeout to 5 seconds in one place and prove with a test using a `MockClient` that never answers (`Completer`) that `NoConnectionException` is thrown.

• **4.** Add a filter to the collection list (only items with a given status) as a getter on the `ChangeNotifier`, with a test, and a `ChoiceChip` row that drives it.

• **5.** Make the collection sort by date instead of by name; the server order must not be mutated in place; a test proves the order.

• **6.** Add a second validator to the form that depends on another field (end date after start date); the error appears under the right field.

• **7.** Add "Duplicate" to the detail screen of a collection item: the form opens prefilled, saving creates a new item on the server.

• **8.** Make the stale banner show how old the cache is ("saved 2 h ago") — the timestamp is written with the file and parsed back.

• **9.** Add a badge with the collection count to the navigation destination using `select`, and show with `debugPrint` that it does not rebuild when a different field changes.

• **10.** Show the error state of the catalogue list in the widget test for a `ServerException(503)` with the status in the text.

• **11.** Add an "Open in browser" action on the detail screen for a URL built from the item's id with `Uri(scheme:, host:, path:)`; handle `false`.

• **12.** Move a setting from `shared_preferences` to the right place or the reverse — the instructor names the value; justify the choice.

• **13.** Add `ENV` to the About screen if missing, and make the app refuse to show the developer host switch in release (prove with a release build's About screen).

• **14.** The planted defect: a `catch (e) {}` somewhere, an `as double` on an `int`, a `read` inside `build`, a missing `mounted`, a `Future` created in `build`, a `Temporary` directory for user data — find it from the symptom, name the slide, fix it.

• **15.** Write the test that would have caught the planted defect before fixing it; it must be red first.

• **16.** Bump the version to the next patch, build the release APK with the production env file, and show the new version in About on the phone.

**Tip:** Build it in the order of the lectures and against the fake first: `core/api` and the sealed exceptions with their tests (week 11 + 13) → the models with `fromJson` tests → one repository with a fake and a `ChangeNotifier` → the first list with four states → the real API → the second feature → storage → the form → the release. The pair that writes `FakeTripRepository` on day one has a demo on day one and a defence machine that works with the Wi-Fi off. The pair that starts with the login screen has neither.

**Useful Links**

1. **MockAPI — a hosted CRUD backend in five minutes:** [mockapi.io](https://mockapi.io)

7. **Mockoon — a local mock server with CRUD routes:** [mockoon.com/docs/latest/api-endpoints/crud-routes](https://mockoon.com/docs/latest/api-endpoints/crud-routes)

2. **Networking cookbook:** [docs.flutter.dev/cookbook/networking/fetch-data](https://docs.flutter.dev/cookbook/networking/fetch-data)

3. **App architecture guide:** [docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture)

4. **Testing: unit, widget, mocking:** [docs.flutter.dev/testing/overview](https://docs.flutter.dev/testing/overview)

5. **Build and release for Android:** [docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)

6. **About pull request reviews:** [docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)

**GOOD LUCK!** :)
