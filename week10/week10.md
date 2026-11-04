**Mobile Development** **Practice 10: The Data Arrives Later**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**The Data Arrives Later**

A fake API that fails → Four states by hand → FutureBuilder done right → A countdown that stops → Errors that do not vanish

In this lab you build the Students screen from the lecture around an API that does not exist yet: a fake one that takes two seconds and fails every third time. First the four states — loading, error, empty, data — by hand with three fields; then the same screen with `FutureBuilder`, done right, with a `Switch` that proves it does not reload; then a countdown that keeps ticking after you leave, until you make it stop; and finally a Save button whose error you first lose in the console and then catch. Next week the fake is replaced by `http` and nothing else changes.

**One sentence carries the whole lab:** the line after `await` runs later. Later the user may have left, the server may have said no, and the widget may be gone. Every level is one place where "later" bites, and the one line that handles it: `mounted`, `try/on`, a `Future` stored in a field, a subscription cancelled in `dispose`.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **A fake API that fails** | `Future.delayed`, `async`, `throw`, `implements Exception`, the event loop order, `unawaited_futures` |
| Level 2 | **Four states by hand** | three fields, `try` / `catch`, `mounted`, `initState` calls but does not await, Retry |
| Level 3 | **FutureBuilder done right** | `late final Future`, `AsyncSnapshot`, `hasError` first, `connectionState`, `data ?? []`, a `Switch` that must not reload |
| Level 4 | **A countdown that stops** | `async*`, `yield`, `StreamBuilder`, `listen`, `StreamSubscription`, `cancel()` in `dispose` |
| Level 5 | **Errors that do not vanish** | an un-awaited `Future`, `await` + `try` / `on`, `context.mounted`, pop only on success |
**Starter Code**

`flutter create students_async`, then copy this into `lib/api/fake_api.dart`. It is the model and the data; the method with the delay is Level 1. `lib/main.dart` is yours: a `MaterialApp` whose `home` is `StudentsScreen` (its own widget, its own file — week 6). Add `unawaited_futures: true` under `linter: rules:` in `analysis_options.yaml` before you write a single `await`.

```dart
class Student {
  const Student({
    required this.name,
    required this.group,
    this.gpa,
  });
  final String name;
  final String group;
  final double? gpa;
}
 
class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});
  final bool empty;   // true -> the server has no students
  int calls = 0;      // how many times fetchStudents() ran

  Future<List<Student>> fetchStudents() async {
    throw UnimplementedError(); // Level 1 replaces this
  }
}
```

---

**Tasks (5)**

**1.** **Level 1: A fake API that fails — and the order of events**

No widgets yet. Make the fake behave like a server, and predict the loop before you run it:

• `fetchStudents()`: `calls++`, then `await Future.delayed(const Duration(seconds: 2))`, then — every third call (`calls % 3 == 0`) — `throw NoConnectionException()`. Otherwise return `empty ? const [] : _seed`. Add `debugPrint('fetchStudents #$calls')` as the first line: from now on the console tells you how many requests your screen makes

• Add `Future<void> save(int value) async` that waits one second and throws `StateError('server rejected $value')` on every second call. Level 5 needs it

• In `main()`, before `runApp`: `print('A'); Future.delayed(const Duration(seconds: 2), () => print('B')); print('C');` and `final api = FakeApi(); api.fetchStudents().then((l) => print('${l.length} students'));` **Before you run it**, write the order you expect into `NOTES.md`. Then run, and write what actually happened next to it

**The test of whether you did this right:**

• The console: `A`, `C`, the first frame of the app — and only two seconds later `B` and `6 students`. Nothing waited for the timer: `main()` ran to the end, the loop drew the screen, and the two callbacks came as events. Call `fetchStudents()` three times in a row from `main()` — the third one prints an `Unhandled Exception: Instance of 'NoConnectionException'` and the app keeps running as if nothing happened. Remember that line: it is Level 5.

• Now break it on purpose: replace `await Future.delayed(...)` with `sleep(const Duration(seconds: 2))` from `dart:io`. The app does not draw its first frame for two seconds — the loop is blocked, not waiting. Put the `await` back and delete the `main()` experiments.

**2.** **Level 2: Loading, error, empty, data — by hand**

`lib/students_screen.dart`, a `StatefulWidget` with three fields and one method:

• `List<Student>? _students;` (null = not loaded yet), `Object? _error;` (non-null = failed), `final _api = FakeApi();`. `initState` calls `_load()` and does **not** await it — `initState` is synchronous and the framework will not wait

• `Future<void> _load() async`: `setState` both fields to null; `try { final list = await _api.fetchStudents(); if (!mounted) return; setState(() => _students = list); } catch (e) { if (!mounted) return; setState(() => _error = e); }`

• `build` is a switch over the fields, in this order: `_error != null` → `ErrorView(onRetry: _load)` with the text "Could not load students" and a Retry button; `_students == null` → `LoadingView` (a centred `CircularProgressIndicator` and "Loading students…"); `_students!.isEmpty` → `EmptyView` ("No students yet" — not a spinner); otherwise `StudentList` — a `ListView.builder` of `ListTile`s, `gpa` shown as `—` when null. Each view is a small `StatelessWidget` in `lib/widgets/`

• Run it with `FakeApi(empty: true)` once to see the fourth state, then switch back

**The test of whether you did this right:**

• Load → two seconds of spinner → the list. Retry three times: the third attempt shows the error view, Retry again shows the list — the fake is deterministic, use that. Open the screen and press Back during the two seconds: nothing in the console. The response arrived at a State that was gone, and `mounted` said so.

• Now break it on purpose: delete both `if (!mounted) return;` lines, open the screen, press Back within two seconds. Red in the console: `setState() called after dispose()`. Copy the first line of that error into `NOTES.md` and put the guards back.

**3.** **Level 3: FutureBuilder — done right, and a Switch that proves it**

`lib/students_future_screen.dart`: the same screen, no fields for the states — and a `Switch` in the `AppBar` that toggles a local `bool _compact` (dense tiles on/off):

• `late final Future<List<Student>> _future;` assigned **once** in `initState`: `_future = _api.fetchStudents();`. `build` returns `FutureBuilder<List<Student>>(future: _future, builder: ...)` — the field, never a call

• The builder, four branches in this order: `snapshot.hasError` → `ErrorView(onRetry: _retry)`; `snapshot.connectionState != ConnectionState.done` → `LoadingView`; `final list = snapshot.data ?? const [];` `list.isEmpty` → `EmptyView`; otherwise `StudentList(list, compact: _compact)`

• `_retry` is the one place a new Future is allowed: `setState(() => _future = _api.fetchStudents());` — so `_future` is `late` but **not** `final` here, and the comment above it says why

• Add a navigation: `main.dart` gets a `home` with two buttons, "By hand" and "FutureBuilder", each pushing its screen (week 6), so both stay in the project

**The test of whether you did this right:**

• Open the FutureBuilder screen, wait for the list, flip the Switch ten times. The console shows **one** `fetchStudents #1` and the list never flickers. Now break it on purpose: `future: _api.fetchStudents()` inline in `build`. Flip the Switch: a spinner on every flip, and the console counts `#2 #3 #4 …` — one request per rebuild, and the third one fails. Put the field back.

• Stop the server: in `FakeApi` make `fetchStudents` always throw for a moment. With the four branches you see the error view and Retry; swap the first two branches (`hasData` first, like the lecture's wrong version) and you get a spinner forever. Restore both.

**4.** **Level 4: A countdown, two ways — and the one that keeps ticking**

`lib/countdown_screen.dart`, reachable from the home screen, with a `from` value of 10:

• `Stream<int> countdown(int from) async*` in `lib/api/countdown.dart`: a `for` loop from `from` down to 0, `await Future.delayed(const Duration(seconds: 1))`, `yield i`, and `debugPrint('tick $i')` right **after** the `yield` — the console is how you will see the leak

• Version A: `late final Stream<int> _stream = countdown(10);` as a field and a `StreamBuilder<int>` that shows `snapshot.data ?? 10` in a big `Text` (`displayLarge`). Nothing else

• Version B, on the same screen behind a `SegmentedButton` or two tabs: `int _left = 10;` `late StreamSubscription<int> _sub;` — in `initState`: `_sub = countdown(10).listen((i) => setState(() => _left = i));` — in `dispose`: `_sub.cancel();` **before** `super.dispose()`

**The test of whether you did this right:**

• Both versions count 10 → 0. Open B, press Back at 7: the console stops at `tick 7`. The subscription was cancelled, the generator stopped at its next `await`, nothing ticked for a dead screen.

• Now break it on purpose: comment out `_sub.cancel()`. Open B, Back at 7. One second later: `setState() called after dispose()` — the same error as Level 2, a different messenger — and the console keeps printing `tick 6`, `tick 5` … all the way to 0 with nobody on screen. That is the leak. Then do the same with version A: no cancel anywhere in your code, Back at 7, and the console stops. `StreamBuilder` cancelled for you. Write both observations into `NOTES.md`; put the `cancel()` back.

**5.** **Level 5: Errors that do not vanish**

A Save button on the by-hand screen (`FloatingActionButton` with a save icon) that calls `_api.save(_students!.length)`:

• First, write it the way the AI writes it: `onPressed: () { _api.save(n); Navigator.pop(context); }`. Run `flutter analyze` — `unawaited_futures` flags the line. Tap Save twice anyway: the second tap pops the screen as if it worked, and the console says `Unhandled Exception: Bad state: server rejected 6`. The user saw a success. Write that sentence into `NOTES.md`

• Then the honest version: `onPressed: () async { try { await _api.save(n); if (!context.mounted) return; Navigator.pop(context); } on StateError catch (e) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))); } }`. Pop only on success; the message only when it failed; `context.mounted` after every `await` because this is a callback, not a `State`

• While the save is in flight the button is disabled and shows a small spinner — a `bool _saving` in `State`, set around the `await` (week 4, slide 31). Tap it fast twice: one request, not two

• `flutter analyze` prints `No issues found!` with `unawaited_futures` on; `dart format .` has been run; `screenshot_error.png` (the error view with Retry) and `screenshot_countdown.png` (version B mid-count) are committed; `NOTES.md` has the predicted and actual order from Level 1, the two error texts, and the two countdown observations

**Tip:** When something async "does not work", ask three questions in this order. Is the Future stored, or created in `build`? (A spinner that flickers on every tap — it is created in `build`.) Is the line after `await` guarded with `mounted`? (A red `setState() called after dispose()` — it is not.) Does anybody `await` this Future at all? (Nothing on screen, an `Unhandled Exception` in the console — nobody does.) Three questions, three lines, and that is the whole lecture.

**Requirements**

• `flutter run` opens a home screen with three ways in: By hand, FutureBuilder, Countdown; `flutter analyze` prints `No issues found!` with `unawaited_futures: true` in `analysis_options.yaml`

• `FakeApi`: `fetchStudents` with a two-second delay, fails every third call with `NoConnectionException`, counts its calls; `save` fails every second call with a `StateError`

• By hand: three fields, `_load` called from `initState` without `await`, `mounted` after every `await`, four views in `lib/widgets/` — loading, error with Retry, empty, list

• FutureBuilder: the Future is a field set in `initState`; `hasError` is checked first; `data ?? []`; an empty list is a screen, not a spinner; flipping the Switch does not call `fetchStudents` again (the console proves it)

• Countdown: `async*` + `yield`; version A with `StreamBuilder`, version B with `listen` and `cancel()` in `dispose`; leaving mid-count leaves the console clean in both

• Save: awaited, `try` / `on StateError`, `context.mounted` after the `await`, pop only on success, a disabled button while in flight; no un-awaited Future anywhere in `lib/`

• `NOTES.md`: the predicted vs actual print order, the exact `setState() called after dispose()` line, the `Unhandled Exception` line, and what the console showed with and without `cancel()`

• `dart format .` has been run; `screenshot_error.png` and `screenshot_countdown.png` are committed

**Useful Links**

1. **Asynchronous programming: futures, async, await:** [dart.dev/libraries/async/async-await](https://dart.dev/libraries/async/async-await)

2. **Asynchronous programming: streams:** [dart.dev/libraries/async/using-streams](https://dart.dev/libraries/async/using-streams)

3. **FutureBuilder:** [api.flutter.dev/flutter/widgets/FutureBuilder-class.html](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)

4. **StreamBuilder:** [api.flutter.dev/flutter/widgets/StreamBuilder-class.html](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)

5. **The unawaited_futures lint:** [dart.dev/tools/linter-rules/unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures)

**GOOD LUCK!** :)
