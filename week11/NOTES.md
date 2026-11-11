# Practice 11 notes

## Level 1: Postman first

The API used is `https://jsonplaceholder.typicode.com`.

| Request | Result |
| --- | --- |
| `GET /users` | HTTP 200, `Content-Type: application/json`, list of 10 users |
| `GET /users/1` | HTTP 200, one user object |
| `GET /users/999` | HTTP 404, empty JSON object `{}` |
| `GET /users?id=3` | HTTP 200, list containing one user |
| `POST /users` | HTTP 201, response contains the submitted fields and server id `11` |

### User fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `id` | number | `int` | no |
| `name` | string | `String` | no |
| `username` | string | `String` | no |
| `email` | string | `String` | no |
| `address` | object | `Address` | no |
| `phone` | string | `String` | no |
| `website` | string | `String?` | yes in the model |
| `company` | object | record | no |

### Address fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `street` | string | `String` | no |
| `suite` | string | `String` | no |
| `city` | string | `String` | no |
| `zipcode` | string | `String` | no |
| `geo` | object | `Geo` | no |

### Geo fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `lat` | string | `double` | no |
| `lng` | string | `double` | no |

### Company fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `name` | string | `String` | no |
| `catchPhrase` | string | `String` | no |
| `bs` | string | not used | no |

The response is a list for `/users` and `/users?id=3`, but an object for
`/users/1`. The nested objects are `address` and `company`; `address.geo` is
nested twice. `lat` and `lng` are strings in the wire format even though the
model will store them as `double`.

## Level 2: models

`Geo`, `Address`, and `User` use `const` constructors, strict casts, nested
`fromJson` calls, and matching `toJson` maps. Coordinates are parsed from the
server's strings with `double.parse`; `website` is the only nullable field in
the model. `User` equality is based on `id`.

## Level 3: repository

`ApiClient` is the only low-level HTTP client. It injects `http.Client`, uses
`Uri.https`, adds a ten-second timeout, maps socket/timeout failures to
`NoConnectionException`, checks status codes before decoding, and converts
invalid JSON to `BadResponseException`.

`UserRepository` exposes only `User` and `List<User>` methods: `getAll`,
`getById`, and `create`. Screens never receive `http.Response` or status codes.

## Level 4: repository to screen

`UsersModel` owns `loading`, `error`, and `items`, and contains no
`BuildContext`, `mounted`, or HTTP code. The composition root creates the
repository and starts `load()` once. `UsersScreen` subscribes with
`context.watch<UsersModel>()`, uses `RefreshIndicator`, and switches
exhaustively on the sealed `ApiException` hierarchy.

## Level 5: two kinds of no network

The repository timeout is 10 seconds. A delayed test client is converted to
the same `NoConnectionException` as a socket failure. The UI therefore uses
one Offline view and one Retry action for both cases.

The New user form validates name, username, and email. Save is disabled while
the POST is in flight, inserts the returned user at the top of the model list,
and closes only after a successful 201 response. API errors stay on the form
and are shown in a SnackBar.

Airplane-mode timing, dead-Wi-Fi timing, and DevTools Network screenshots were
not captured in this environment because no real Flutter device or DevTools
Network session was available. No screenshots were fabricated.

# Practice 12 — заметки

## Level 1 — пакеты и версии

- `shared_preferences`: publisher Flutter, опубликован в октябре 2026, Android/iOS и другие платформы, pub points 160; пакет поддерживается, зависит от platform-interface и платформенных реализаций, лицензия BSD-3-Clause; подходит для некритичных настроек.
- `flutter_secure_storage`: publisher steenbakker.dev, опубликован в сентябре 2026, Android/iOS и другие платформы, pub points 160; есть свежие изменения и работающие issue, зависимости нужны для Keychain/Keystore, лицензия BSD-3-Clause; подходит для токена.
- `path_provider`: publisher Flutter, опубликован в июле 2026, Android/iOS и другие платформы, pub points 160; поддерживается, зависит от platform-interface и платформенных реализаций, лицензия BSD-3-Clause; даёт Documents directory.
- `image_picker`: publisher Flutter, опубликован в октябре 2026, Android/iOS и другие платформы, pub points 160; пакет регулярно обновляется, зависит от `image_picker_platform_interface` и реализаций платформ, лицензия BSD-3-Clause; подходит для галереи и камеры.
- `permission_handler`: publisher baseflow.com, опубликован в сентябре 2026, Android/iOS и другие платформы, pub points 160; есть свежие коммиты и открытые issue, зависит от platform-interface и нативных реализаций, лицензия MIT; нужен для runtime-разрешений.
- `url_launcher`: publisher Flutter, опубликован в октябре 2026, Android/iOS и другие платформы, pub points 160; поддерживается, зависит от platform-interface и реализаций платформ, лицензия BSD-3-Clause; открывает `mailto`, `tel` и `https`.

Установлены одной командой `flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher`. В `pubspec.yaml` записались caret-ограничения: `shared_preferences: ^2.5.6`, `flutter_secure_storage: ^11.2.0`, `path_provider: ^2.1.6`, `image_picker: ^1.2.4`, `permission_handler: ^13.0.2`, `url_launcher: ^6.3.3`. В `pubspec.lock` для `http` зафиксирована версия `1.6.0`.

Диапазон `^1.2.0` означает `>=1.2.0 <2.0.0`: принимает `1.2.0` и более новые `1.x`, но отказывает `1.1.9` и `2.0.0`. `pubspec.lock` коммитится в приложении, чтобы одинаковый resolver использовал одинаковые точные версии зависимостей.

`flutter pub outdated` показал, что `cupertino_icons` уже ограничен старой major-веткой (`1.0.9`, resolvable `2.0.0`), а часть транзитивных пакетов можно обновить. Массовое обновление не выполнялось: оно не требовалось заданием и могло изменить рабочий lock-файл.

Для этой практики оставлены только `android` и `ios`; дополнительные desktop/web-платформы не добавлялись. `practice12.md` использован как ТЗ и не изменён.

## Level 2 — что переживает перезапуск

`darkMode` и `cityFilter` читаются в `main()` до `runApp`, поэтому тема не вспыхивает светлой. Простые настройки лежат в `shared_preferences`; токен туда не записывается.

## Level 3 — безопасный токен

Токен хранится в Keychain/Keystore через `SecureStore`. В обычном XML/plist `prefs.setString('token', ...)` он был бы доступен из файла приложения, резервной копии, root-доступа или через кабель. iOS Keychain может пережить удаление приложения, а Android-ключ может стать недоступным после удаления lock screen — это нужно учитывать при logout и восстановлении сессии.

## Level 4 — offline cache

`users.json` хранится через `getApplicationDocumentsDirectory()`, а не во временной папке. При `NoConnectionException` репозиторий возвращает последнюю сохранённую коллекцию с `fromCache: true`; если файла нет, ошибка пробрасывается дальше.

## Level 5 — permission и ссылки

Камера запрашивается только по нажатию: `denied` показывает SnackBar, `permanentlyDenied` — собственный диалог и `openAppSettings()`, остальные статусы (`restricted`, `limited`, `provisional`) тоже обработаны. Отмена выбора фото даёт `null` и ничего не ломает. На iOS для Photos дополнительно существует статус `limited`.

Ссылки собираются как `mailto:`, `tel:` через `phoneDigits` и `https:` для сайта; возвращаемый `bool` от `launchUrl` превращается в сообщение `No app can open this`.

Скриншоты `screenshot_offline_banner.png` и `screenshot_permission_dialog.png` не создавались без реального устройства/эмулятора: файлы не подменялись искусственными изображениями.

# Practice 13 — заметки

## Level 1 — feature-first

Проект уже имел `core/` и `features/` после Practice 11–12, поэтому сохранены рабочие перемещения и добавлен `tool/check_layers.sh`. Скрипт проверяет, что HTTP-клиент не просачивается в UI, а Material не используется моделями и репозиториями. `main.dart` создаёт production HTTP-клиент через фабрику API, поэтому `package:http` остаётся в разрешённых слоях.
