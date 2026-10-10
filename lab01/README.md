# Widget Anonymous

A support-group app for Flutter developers to confess their worst bugs.
Browse upcoming (and past) confession circles, join the ones that hit too
close to home, favourite the classics, and keep a profile so the app knows
which lists you're already on.

Built for Mobile Development Lab 1: a single multi-screen Flutter app, no
external packages beyond `flutter_lints`/`cupertino_icons`.

## Running it

```
flutter pub get
flutter run
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed .
```

Resize the window to 600px+ wide (or run on a tablet) to see the sessions
list switch from a `ListView` to a responsive `GridView`.

> Screenshots aren't included in this submission — the only toolchain
> available while building this was `flutter run -d edge` (the Windows
> desktop target needs a C++ compiler that wasn't installed here), and
> no screen-capture tool was wired up for that session. The widget tests
> in `test/widget_test.dart` exercise the main flows end-to-end instead.

## Structure

Flat `lib/`, one file per concern:

- `session.dart` — the `Session` model, `BugType` enum, category-color
  helpers, and the `Countdown` sealed class.
- `profile.dart` — the `Profile` model.
- `utils/format.dart` — date formatting without `intl`.
- `theme.dart` — Material 3 light/dark `ThemeData` from one seed color.
- `routes.dart` — route-name constants and the two navigation-argument
  classes.
- `session_card.dart`, `empty_state.dart` — shared widgets.
- `sessions_tab.dart`, `favourites_tab.dart`, `profile_tab.dart` — the
  three tabs.
- `app_shell.dart` — owns the session list, profile, and tab index; the
  only place sessions get created, edited, deleted, or favourited.
- `session_detail_screen.dart`, `session_form_screen.dart` — pushed
  screens.
- `main.dart` — `MaterialApp` + theme-mode state + route generation.

## Decisions

- **No `id` field on `Session`.** The spec doesn't call for one, so list
  mutations (favourite, join/leave, edit, delete) are done by reference
  identity (`identical()`) against the live `_sessions` list in
  `AppShell`, closed over at the point each session's card/detail screen
  is opened. Simpler than inventing an id generator for twelve seed items.
- **`SessionDetailArgs` carries a `Profile` snapshot**, not just the
  session and callbacks. The detail screen needs `profile.name` for the
  join/leave flow and the "Names" tab's "you" row; passing it down at
  push-time keeps the screen free of any ambient/global state.
- **Category images are generated placeholders**, not real illustrations
  (flat shapes on a themed background), one per `BugType`, since the
  brief only asked for "an image per category" and didn't require actual
  artwork.
- **Everywhere outside `theme.dart`, colors come from `ColorScheme`**,
  not literals — including the category badges, which use a second
  `onCategoryColor()` helper so icon/text stay legible against their
  tinted background in both light and dark mode.
