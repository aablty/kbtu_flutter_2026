**Mobile Development** **Practice 14: Ship It**

---

**Submission:** Upload your work to GitHub repo till the next practice lesson

**Ship It**

Identity and version → a key you never commit → one codebase, three environments → icon and splash → the release and the checklist

In this lab the users app leaves your laptop. By the end there is a file another person can install: a release APK, signed with a key that is yours, with a real name and icon, a version the store would accept, a host baked in at build time, and an About screen that tells you which build you are holding. Every step is a file or a command, not Dart — and every step is one of the fourteen boxes on the lecture's checklist.

**One sentence carries the whole lab:** a release is a release when all fourteen boxes are ticked, not when the build command succeeds. The APK you install from a file on a real phone, on mobile data, the day before — that is the one that counts.

**Build Levels**

| **Level** | **Topic** | **Key Widgets** |
| --- | --- | --- |
| Level 1 | **Identity and version** | `applicationId`, `minSdk`, `version: 1.0.0+1`, `versionCode` / `versionName`, `package_info_plus` |
| Level 2 | **A key you never commit** | `keytool`, `upload-keystore.jks`, `key.properties`, `.gitignore`, `signingConfigs`, `buildTypes.release` |
| Level 3 | **Environments** | `--dart-define`, `String.fromEnvironment`, an `Env` class, `--dart-define-from-file`, `USE_FAKES` |
| Level 4 | **Icon, splash, About** | `flutter_launcher_icons`, `flutter_native_splash`, Android 12, `kReleaseMode`, `showLicensePage` |
| Level 5 | **The release** | `--release --split-per-abi --obfuscate --split-debug-info`, `flutter symbolize`, a real phone, the fourteen boxes |
**Starter Code**

Continue in the Practice 11–13 repository. `lib/core/env.dart` is the one new Dart file; copy it. Everything else today is `pubspec.yaml`, `android/app/build.gradle.kts`, `android/key.properties`, `.gitignore` and the terminal.

`// lib/core/env.dart — the only file that knows the variable names`

`abstract final class Env {`

`  static const host = String.fromEnvironment(`

`    'API_HOST',`

`    defaultValue: 'jsonplaceholder.typicode.com',`

`  );`

`  static const useFakes = bool.fromEnvironment('USE_FAKES');`

`  static const name = String.fromEnvironment('ENV', defaultValue: 'local');`

`}`

` `

`// main.dart — the commented line from Practice 13 becomes a const switch`

`final UserRepository repo = Env.useFakes`

`    ? FakeUserRepository()`

`    : HttpUserRepository(ApiClient(http.Client(), host: Env.host));`

` `

`// env/prod.json  (gitignored only if it ever holds a key)`

`// { "API_HOST": "jsonplaceholder.typicode.com", "ENV": "prod" }`

---

**Tasks (5)**

**1.** **Level 1: Identity and version**

Two numbers and one id, set once and never guessed again:

• `android/app/build.gradle.kts`: `applicationId = "kz.<yourname>.users"` (reverse-domain, lower case, never `com.example`), `namespace` the same; `minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion`, `versionCode = flutter.versionCode`, `versionName = flutter.versionName` — read from pubspec, never typed here. Nothing else in that file is yours to tidy

• `pubspec.yaml`: `version: 1.0.0+1`, and `name:` / `description:` that say what the app is. Write into `NOTES.md` what each half of `1.0.0+1` is for, who reads it (people vs. the store), and which half must change on every upload

• `flutter pub add package_info_plus`; an `AboutScreen` reachable from Settings that shows `Version ${info.version} (${info.buildNumber})`, the build mode (`kReleaseMode ? 'release' : kProfileMode ? 'profile' : 'debug'`), `Env.name`, `Env.host`, and a tile that calls `showLicensePage(context: context)`

**The test of whether you did this right:**

• The About screen says `1.0.0 (1) · debug · local · jsonplaceholder.typicode.com`. Change pubspec to `1.0.1+2`, hot restart: `1.0.1 (2)` — you edited one file. Break it on purpose: hard-code `versionCode = 1` in the Gradle file and bump pubspec to `+3`; the About screen still says `(1)`. That is the third-upload rejection from the lecture, reproduced on your desk. Put `flutter.versionCode` back.

**2.** **Level 2: A key you never commit**

Your own upload key, a properties file that points to it, and a repository that never sees either:

• `.gitignore` **first**: add `*.jks`, `*.keystore`, `android/key.properties`, `env/*.local.json`. Commit this line before the key exists

• `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` — outside the project folder. Back the file up somewhere that is not this laptop and write where in `NOTES.md` (not the password)

• `android/key.properties` with `storePassword`, `keyPassword`, `keyAlias=upload`, `storeFile=/absolute/path/upload-keystore.jks`. In `build.gradle.kts`: load it into `keystoreProperties`, `signingConfigs { create("release") { … } }`, and `buildTypes { release { signingConfig = signingConfigs.getByName("release"); isMinifyEnabled = true } }` — exactly as the lecture shows; `getByName("debug")` in the release block is the mistake to look for

**The test of whether you did this right:**

• `git status` shows neither `key.properties` nor the `.jks` as untracked — they are ignored. `flutter build apk --release` succeeds and `keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk` prints **your** alias and organisation, not "Android Debug". Then write in `NOTES.md` what a classmate could do with your key and your `applicationId` if you had committed them, what Play App Signing changes about that, and the two commands that scrub a file from git history.

**3.** **Level 3: One codebase, three environments**

Local, staging, production — and a fakes build for a machine with no network — with no edited files and no `if (isProd)`:

• `lib/core/env.dart` from the starter; `main.dart` chooses the repository through `Env.useFakes`; `ApiClient` takes `host: Env.host`. Nobody else calls `fromEnvironment` — `grep -rn fromEnvironment lib/` prints only `env.dart`

• `env/local.json` (`API_HOST` = a host of your laptop or the public one, `ENV` = `local`), `env/prod.json` (`ENV` = `prod`). Four ways to run, all written into `README.md`: `flutter run` (defaults), `flutter run --dart-define=USE_FAKES=true` (no network), `flutter run --dart-define-from-file=env/local.json`, `flutter build apk --release --dart-define-from-file=env/prod.json`

• A developer-only switch, **gated**: `if (kDebugMode) ListTile(title: const Text('Developer: API host'), …)` in Settings that lets a tester pick a host at runtime and stores it in `shared_preferences`. Write in `NOTES.md` why this cannot be done with `fromEnvironment`, and why it must never be visible in a release build

**The test of whether you did this right:**

• `flutter run --dart-define=USE_FAKES=true` with airplane mode on: the app opens with two users and the About screen says the host — it never tried the network. `--dart-define=ENV=staging --dart-define=API_HOST=example.invalid`: the About screen shows both values and the users list shows the Offline view, because that host does not exist. A release APK built from `env/prod.json` shows `prod` in About. Break it on purpose: build the release **without** the env file and install it on a phone — if your local host was `10.0.2.2:8080`, the list is empty and About tells you why in one line. That is question 6 of the lecture, on your own phone.

**4.** **Level 4: An icon, a splash and a name**

Twenty minutes that separate a lab from an app:

• A 1024×1024 PNG icon of your own (no alpha for iOS) and a foreground layer for Android's adaptive icon; a splash image and an Android 12 image (1152², the icon inside a 768 circle). `flutter pub add --dev flutter_launcher_icons flutter_native_splash`; the two YAML blocks from the lecture in `pubspec.yaml`; `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`. Commit the generated platform files

• The app's display name: `android:label` in `AndroidManifest.xml` and `CFBundleDisplayName` in `Info.plist` — "Users", not "users_api"

• `INTERNET` permission in the **main** `AndroidManifest.xml` (`<uses-permission android:name="android.permission.INTERNET"/>`) — the debug manifest declares it for you, the release one does not; this is suspect number two in the lecture's question 6

**The test of whether you did this right:**

• On the emulator's home screen: your icon, your name. Cold start: your splash, then the app — no white screen with the Flutter logo. On an Android 12+ image the splash shows your icon on your colour. Remove the `INTERNET` line on purpose, `flutter build apk --release`, install, open: the Offline view instantly and forever. Put it back and rebuild.

**5.** **Level 5: The release — and the fourteen boxes**

The artefact, the symbols, a real phone, and a checklist with every box ticked:

• `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json`. Three APKs appear; `app-arm64-v8a-release.apk` is the one for a phone in your hand. Note its size next to `flutter build apk --debug`'s in `NOTES.md`

• Archive together, as the lecture's rule says: `releases/1.0.1+2/` with the arm64 APK and the `symbols/` folder (this folder is gitignored or kept outside the repo — symbols are per build). Write in `NOTES.md` what a crash log looks like without them and the `flutter symbolize` command that turns it back into file names

• Install the APK on a **real phone from the file**, over mobile data, not from the IDE. First launch; airplane-mode launch (the offline list from Practice 12 must appear); Take photo with a denied permission; rotate; the About screen — version, `release`, `prod`, the host

• `flutter build appbundle --release --dart-define-from-file=env/prod.json` once, so you have seen the `.aab` and know it cannot be installed. A GitHub Release `v1.0.1` with the arm64 APK attached and the version from pubspec in its title — "Try it on your phone" is the line a junior CV can back up

• The fourteen boxes from the lecture's pre-release checklist, copied into `README.md` as a checklist and **all ticked**, each with one word of proof where it applies (a command, a file, a screenshot name). `screenshot_about_release.png` from the real phone, `screenshot_release_page.png` of the GitHub Release

**The test of whether you did this right:**

• A classmate installs your APK from the GitHub Release on their phone and sees your icon, your splash, the users list over mobile data and `1.0.1 (2) · release · prod` in About — without you touching their phone. `git log` shows no keystore ever committed (`git log --all --diff-filter=A --name-only | grep -e jks -e key.properties` prints nothing). Fourteen ticks, each one defensible in a sentence.

**Tip:** Three things you cannot fix after someone has installed the app: the `applicationId` (it is the identity — change it and the store sees a new app), the signing key (lose it and you cannot update — back it up today, enrol in Play App Signing on the first upload), and a build number that did not go up (the store refuses the upload). Everything else — a wrong host, a missing permission, an ugly icon — is a new build away. Spend your care on those three.

**Requirements**

• `applicationId` is reverse-domain and yours; `minSdk` / `targetSdk` / `versionCode` / `versionName` come from `flutter.*`; `pubspec.yaml` `version` has been bumped at least once (`1.0.1+2` or later)

• `.gitignore` covers `*.jks`, `*.keystore`, `android/key.properties`; the release is signed with your key (`keytool -printcert` output in `NOTES.md`); no secret has ever been committed

• `lib/core/env.dart` is the only file with `fromEnvironment`; `USE_FAKES=true` runs the app offline; `env/local.json` and `env/prod.json` exist; the four run / build commands are in `README.md`

• The About screen shows version, build number, mode, `Env.name` and `Env.host`, and opens the licence page; the developer host switch exists only behind `kDebugMode`

• Your icon (adaptive on Android), your splash (Android 12 included), your app name; `INTERNET` declared in the main manifest

• `releases/<version>/` with the arm64 APK built with `--obfuscate --split-debug-info`; the symbols archived with it; a GitHub Release with the APK attached

• The APK was installed from the file on a real phone over mobile data; `screenshot_about_release.png` and `screenshot_release_page.png` are committed

• The fourteen-box checklist in `README.md`, every box ticked with its proof; `flutter analyze` 0, `dart format .` clean, `flutter test` green, the layer `grep` empty

**Useful Links**

1. **Build and release an Android app:** [docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)

2. **Obfuscate Dart code:** [docs.flutter.dev/deployment/obfuscate](https://docs.flutter.dev/deployment/obfuscate)

3. **Flavors and --dart-define:** [docs.flutter.dev/deployment/flavors](https://docs.flutter.dev/deployment/flavors)

4. **flutter_launcher_icons:** [pub.dev/packages/flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

5. **flutter_native_splash:** [pub.dev/packages/flutter_native_splash](https://pub.dev/packages/flutter_native_splash)

6. **Play App Signing:** [support.google.com/googleplay/android-developer/answer/9842756](https://support.google.com/googleplay/android-developer/answer/9842756)

**GOOD LUCK!** :)
