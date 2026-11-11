**Mobile Development** **Practice 12: Survive a Restart**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**Survive a Restart**

Read a package page → a setting that persists → a token that persists safely → the offline list → a photo and a No

In this lab the users app from Practice 11 learns to survive three things: a restart, the metro, and a user who says No. Settings go to `shared_preferences` and are read before `runApp`; a token from a fake login goes to the Keychain / Keystore and comes back as an `Authorization` header; the repository keeps the last good list in a file and returns it when the network is gone; and a profile photo comes from the camera through the full permission flow — including the state where the OS will never ask again.

**One sentence carries the whole lab:** three places to keep things. `shared_preferences` for settings, secure storage for anything that lets someone be you, a file in Documents for data — and `Temporary` is temporary. Every package you add today you first evaluate in two minutes, out loud, in `NOTES.md`.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **Read a package page** | publisher, last release, platforms, pub points, issues, dependencies, example; `^caret`, `pubspec.lock` |
| Level 2 | **A setting that persists** | `SharedPreferencesAsync`, nullable reads, `WidgetsFlutterBinding.ensureInitialized`, read before `runApp` |
| Level 3 | **A token that persists safely** | `flutter_secure_storage`, `write` / `read` / `delete`, the `Authorization` header, sign out |
| Level 4 | **The offline list** | `path_provider`, `getApplicationDocumentsDirectory`, `File`, the JSON round trip, a stale banner |
| Level 5 | **A photo and a No** | `image_picker`, `permission_handler`, manifest and `Info.plist`, `permanentlyDenied`, `openAppSettings`, `url_launcher` |
**Starter Code**

Continue in the Practice 11 repository. This is the shape `main.dart` takes by the end of Level 2 — the order matters: the binding, then the disk, then `runApp`. Copy it and fill the gaps as you go.

`import 'package:flutter/material.dart';`

`import 'package:http/http.dart' as http;`

`import 'package:provider/provider.dart';`

`import 'package:shared_preferences/shared_preferences.dart';`

` `

`Future<void> main() async {`

`  WidgetsFlutterBinding.ensureInitialized(); // before any plugin`

` `

`  final prefs = SharedPreferencesAsync();`

`  final dark = await prefs.getBool('darkMode') ?? false;`

`  final city = await prefs.getString('cityFilter'); // String?`

` `

`  final api = ApiClient(http.Client());`

` `

`  runApp(MultiProvider(`

`    providers: [`

`      ChangeNotifierProvider(`

`        create: (_) => SettingsModel(prefs, dark: dark, city: city),`

`      ),`

`      ChangeNotifierProvider(`

`        create: (_) => UsersModel(UserRepository(api))..load(),`

`      ),`

`    ],`

`    child: const App(),`

`  ));`

`}`

---

**Tasks (5)**

**1.** **Level 1: Read a package page in two minutes**

Before any `flutter pub add`, a verdict in `NOTES.md` for each of the five packages you will use today — `shared_preferences`, `flutter_secure_storage`, `path_provider`, `image_picker`, `permission_handler` — plus `url_launcher`:

• One sentence each, in the lecture's order: publisher (verified? who?), last release (month and year), platforms, pub points, open issues vs. recent commits, what it depends on, licence. "Verified publisher flutter.dev, released last month, all six platforms, 160 points, MIT, no dependencies of note" is a verdict; "popular" is not

• Add them with `flutter pub add` (one command, all six) and read the carets it wrote. Open `pubspec.lock` and find the exact version pub resolved for `http`. Write into `NOTES.md` which versions `^1.2.0` would accept and which it would refuse, and why `pubspec.lock` is committed for an app

• Run `flutter pub outdated`. Note one package that could be newer and the reason it was not upgraded

**The test of whether you did this right:**

• Six verdicts, each one sentence you could say out loud at the defence. `pubspec.lock` is in git. Break it on purpose: change `http: ^1.2.0` to `http: 1.2.0` (no caret) and run `flutter pub get` — the lock now pins exactly 1.2.0 and `pub outdated` shows everything newer as unavailable. Put the caret back.

**2.** **Level 2: A setting that survives a restart**

Dark mode and the last city filter, read before the first frame:

• `SettingsModel extends ChangeNotifier` takes the `SharedPreferencesAsync` and the initial values through its constructor; `setDark(bool v)` sets the field, calls `notifyListeners()` **first**, then `await _prefs.setBool('darkMode', v)` — the screen must not wait for the disk. `setCity(String? c)` writes or `remove`s the key

• `MaterialApp(themeMode: context.watch<SettingsModel>().dark ? ThemeMode.dark : ThemeMode.light, theme: ..., darkTheme: ...)` — the two themes from week 5. A Settings screen with a `SwitchListTile` for dark mode and a `DropdownButtonFormField` of cities taken from the loaded users; the users list filters by the chosen city

• Every read from preferences is nullable and gets a default with `??` — no `!`, no `late`

**The test of whether you did this right:**

• Switch dark on, pick a city, kill the app from the switcher (not just Back), reopen: dark from the very first frame — no flash of a light theme — and the city filter already applied. Then break it on purpose: move the `getBool` into `SettingsModel`'s constructor with a default of `false` and read it later. Reopen the app: one light frame, then dark. That flash is why the read happens in `main()` before `runApp`. Put it back.

**3.** **Level 3: A token that survives — safely**

A fake login, a real secure store, and a header the repository adds by itself:

• `SecureStore` in `lib/core/storage/secure_store.dart` wraps `const FlutterSecureStorage()`: `Future<void> saveToken(String)`, `Future<String?> readToken()`, `Future<void> clear()`. `AuthModel extends ChangeNotifier` with `bool get signedIn`, `Future<void> login(String email, String password)` — the fake: any password of 8+ characters returns `'tok_${email.hashCode}'` after one second — and `Future<void> logout()` that calls `clear()`. At startup `main()` reads the token and hands it to `AuthModel`

• `ApiClient` gets the `SecureStore` through its constructor and builds headers with `if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t'` — the repository never sees the token, the screen never sees the header

• A Login screen (the form from week 7) that the app shows while `signedIn` is false, and a Sign out tile in Settings. The `UserDetailScreen` gets a "Copy token to clipboard" button **behind** `if (kDebugMode)` so you can prove the header exists without logging it

**The test of whether you did this right:**

• Log in, kill the app, reopen: still signed in, and DevTools → Network shows `Authorization: Bearer tok_…` on the next request. Sign out, reopen: the login screen. Then write in `NOTES.md` where `prefs.setString('token', …)` would have put the token (a plain XML file / plist in the app folder) and who can read it (a backup, root, a cable) — and the two platform surprises from the lecture: what iOS Keychain may do after an uninstall, and what Android may do when the lock screen is removed.

**4.** **Level 4: The offline list**

The repository remembers the last good answer; the screen says when it is showing it:

• `UsersCache` in `lib/features/users/users_cache.dart`: `getApplicationDocumentsDirectory()` → `users.json`; `save(List<User>)` writes `jsonEncode([for (final u in list) u.toJson()])`; `load()` returns `null` when the file does not exist, otherwise the parsed list. Never a hard-coded path; never `getTemporaryDirectory()` for this file

• `UserRepository.getAll()`: `try { final fresh = await _fetch(); await _cache.save(fresh); return fresh; } on NoConnectionException { final saved = await _cache.load(); if (saved == null) rethrow; return saved; }`. Make the result say where it came from: return a record `({List<User> items, bool fromCache})`, or a small `UsersResult` class

• `UsersModel` gets `bool fromCache`; the screen shows a `MaterialBanner` or a thin coloured strip — "Saved data · no connection · Retry" — above the list when it is true, and nothing when it is false

**The test of whether you did this right:**

• Load once online. Airplane mode on, kill the app, reopen: the ten users are there instantly with the banner; Retry under airplane mode keeps them and keeps the banner; airplane mode off, Retry: the banner disappears. Delete the app (not just kill), reinstall, airplane mode on, open: the honest Offline screen — `saved == null`, `rethrow` — not an empty list.

• Break it on purpose: write the file to `getTemporaryDirectory()` and, in the emulator, Settings → Apps → your app → Storage → Clear cache. Reopen offline: the list is gone, no error. The OS kept the promise the directory's name made. Put Documents back.

**5.** **Level 5: A photo and a No**

A profile photo from the camera or the gallery, with every answer the OS can give handled — and three links to three apps:

• Declare first. Android: `<uses-permission android:name="android.permission.CAMERA" />` in `AndroidManifest.xml`. iOS: `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `Info.plist` with a sentence a user would accept. Without the plist key iOS kills the app the moment the camera is touched

• A Profile screen: a `CircleAvatar` with the photo or an initial; "Choose photo" → `ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85)`; "Take photo" → `Permission.camera.request()` **at the moment of the tap**, never in `initState`, then a `switch` on the status: `granted` → pick; `denied` → a `SnackBar` that explains; `permanentlyDenied` → your own `AlertDialog` with "Open settings" → `openAppSettings()`. `pickImage` returns `null` on Cancel — the three lines from week 6: null check, `mounted`, `setState`. Copy the picked file into Documents as `avatar.jpg` and remember the path in `shared_preferences`, so the photo survives a restart

• The user detail screen gets its links: the email opens `mailto:`, the phone opens `tel:` (use `phoneDigits` from Practice 11), the website opens `https://` + the value — all through `launchUrl`, built with `Uri(scheme:, path:)` / `Uri.parse`, and the returned `bool` checked: `false` → "No app can open this". Android 11+: the `<queries>` block for the schemes you use

• `flutter analyze` clean, `dart format .` run, `screenshot_offline_banner.png` and `screenshot_permission_dialog.png` (your own dialog for the denied-forever state) committed

**The test of whether you did this right:**

• Android emulator: tap Take photo, Don't allow; tap again, Don't allow; tap a third time — no system dialog, your dialog at once, "Open settings" lands in the app's permission page. Reset the permission in Settings and do it again. In `NOTES.md` write the same sequence for iOS: how many No's until `permanentlyDenied`, and what the fourth Photos state is called. Then break it on purpose: `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme — `false`, nothing opens; add `https://` and the browser opens.

**Tip:** Every device API today answers the same way as `showDialog` and `push` did: an `await`, and a `null` (or `false`, or a `denied`) when the user backed out. `pickImage` → `null` on Cancel, `launchUrl` → `false` with no app, `request()` → an enum with four values you must all handle. The crash in every student app this week is a `!` after one of those awaits. Handle the No; the feature keeps working without the photo, and that sentence is what you say at the defence.

**Requirements**

• `NOTES.md`: six one-sentence package verdicts in the lecture's order; what the caret accepts; why `pubspec.lock` is committed; the storage and permission answers from Levels 3 and 5

• Dark mode and the city filter in `shared_preferences`, read in `main()` before `runApp` — no flash of the wrong theme; `notifyListeners()` before the disk write; every read `??`-defaulted

• Fake login → token in `flutter_secure_storage` through `SecureStore`; `ApiClient` adds `Authorization: Bearer …` by itself; sign out deletes it; the token is never printed and never in `shared_preferences`

• `UsersCache` in `getApplicationDocumentsDirectory()`; `getAll()` saves on success and returns the cache on `NoConnectionException`, `rethrow`s when there is nothing; the screen shows a stale banner only when the data is from the cache

• Take photo: declared in the manifest and `Info.plist`, requested at the tap, all four statuses handled, `permanentlyDenied` → your dialog → `openAppSettings()`; Cancel → `null` handled; the photo survives a restart

• `mailto:`, `tel:`, `https:` through `launchUrl` with the `bool` checked; `<queries>` declared on Android

• No `!` after any device `await`; `flutter analyze`: `No issues found!`; `dart format .`; `unawaited_futures` on; the `grep` for `package:http` still prints only the two files

• `screenshot_offline_banner.png` and `screenshot_permission_dialog.png` are committed

**Useful Links**

1. **Store key-value data on disk (cookbook):** [docs.flutter.dev/cookbook/persistence/key-value](https://docs.flutter.dev/cookbook/persistence/key-value)

2. **Read and write files (cookbook):** [docs.flutter.dev/cookbook/persistence/reading-writing-files](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)

3. **flutter_secure_storage:** [pub.dev/packages/flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

4. **image_picker:** [pub.dev/packages/image_picker](https://pub.dev/packages/image_picker)

5. **permission_handler:** [pub.dev/packages/permission_handler](https://pub.dev/packages/permission_handler)

6. **url_launcher:** [pub.dev/packages/url_launcher](https://pub.dev/packages/url_launcher)

**GOOD LUCK!** :)
