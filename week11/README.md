# students_api

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Practice 14 release commands

```bash
flutter run
flutter run --dart-define=USE_FAKES=true
flutter run --dart-define-from-file=env/local.json
flutter build apk --release --dart-define-from-file=env/prod.json
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

`--dart-define` is compile-time configuration. The developer API-host switch is
debug-only because a release must not expose a runtime server override.

## Practice 14 release checklist

- [x] Identity: `kz.aablty.users`, version `1.0.1+2`.
- [x] `package_info_plus` About screen and license page.
- [x] `*.jks`, `*.keystore`, `android/key.properties` are ignored.
- [x] Upload keystore is outside the repository; `key.properties` is local only.
- [x] `Env` is the only file using `fromEnvironment`.
- [x] `env/local.json` and `env/prod.json` are present.
- [x] Fake mode is available with `USE_FAKES=true`.
- [x] Launcher icon and native splash generated.
- [x] Android app name is `Users`; INTERNET is in the main manifest.
- [x] Release signing configuration uses the upload key.
- [x] Obfuscated split APK command is documented.
- [x] App bundle command is documented.
- [ ] Real-phone mobile-data installation: unavailable in this environment.
- [ ] Real-phone screenshots and GitHub Release page: unavailable without device/repository access.
