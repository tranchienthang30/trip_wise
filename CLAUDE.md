# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app named `trip_wise` (branded "Tripwise") — a travel booking / provider management UI. Currently a UI-only prototype: no backend, no state management library, no persistence. All screens use `StatefulWidget` + local `setState` and display hardcoded data.

- Flutter SDK: `^3.9.2` (Dart)
- Only non-trivial dependency: `cupertino_icons`. Lints via `flutter_lints` (default rules, see `analysis_options.yaml`).

## Commands

```bash
flutter pub get                       # install deps
flutter run                           # run on currently selected device
flutter run -d chrome                 # run web build
flutter analyze                       # static analysis / lint
flutter test                          # run all widget tests
flutter test test/widget_test.dart    # run a single test file
flutter test --name "smoke test"      # run tests matching a name
flutter build apk / ipa / web         # release builds
```

Platforms enabled: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` (all stock Flutter scaffolding).

## Architecture

```
lib/
├── main.dart              # MaterialApp + named routes. `home:` is swapped to whichever
│                          # screen is actively being developed — it is NOT a real landing page.
├── constants/
│   ├── colors.dart        # TripwiseColors — Material 3 palette constants
│   └── theme.dart         # TripwiseTheme.light — applied via MaterialApp.theme
├── screens/               # One file per screen; each a self-contained StatefulWidget
├── widgets/               # Shared widgets (currently mostly empty scaffolding)
├── models/                # Plain Dart data classes (scaffolding)
└── services/              # Mock data providers — not wired to any network layer
```

### Routing

Named routes are registered in `lib/main.dart`. Adding a screen means: create the file under `lib/screens/`, import it in `main.dart`, and add an entry to the `routes:` map. Navigate via `Navigator.pushNamed(context, '/route_name')`.

Current registered routes: `/home`, `/search_filter`, `/my_trips`, `/booking_checkout`, `/profile_registration`, `/provider_finance`, `/provider_listings`.

### Theming

All screens consume the central `TripwiseTheme.light` and `TripwiseColors` — do not hardcode colors, typography, radii, or button styles in screen files. Font family is `Inter` (referenced by `ThemeData.fontFamily` but no font asset is declared in `pubspec.yaml`, so it falls back to the platform default until assets are added).

### State management

Intentionally simple: `StatefulWidget` + `setState`. No Provider/Riverpod/Bloc. Keep new screens in this shape unless the user explicitly asks to introduce a state library.

## Known gotchas

- `lib/main.dart`'s `home:` currently points at one specific screen (e.g. `ProviderFinancePayoutScreen`) for ad-hoc preview during development — treat it as a dev harness, not the product entry point.
- `test/widget_test.dart` is the default Flutter counter-app template and does not match the real `MyApp`; it will fail if run. `flutter test` is effectively unverified until tests are rewritten.
- `IMPLEMENTATION_SUMMARY.md` / `SCREENS_IMPLEMENTATION.md` are historical design notes — they may drift from the actual code as screens are added. Trust `lib/` over those docs.
