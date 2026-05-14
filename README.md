# Tripwise

Tripwise is a Flutter UI prototype for a full-service travel platform. It connects travelers with providers for hotels, tours, transportation, premium services, trip planning, payments, and provider operations. The project currently focuses on a polished mobile-first experience, consistent UI foundations, and core product flows before backend integration.

## Overview

Tripwise is a cross-platform Flutter prototype with declarative routing, a Material 3 theme, traveler/provider screens, and mock data for product demos.

Core experience areas:

- Search and book travel services.
- Plan trips with dashboards, timelines, and itinerary tools.
- Manage booked trips, wallet, payments, and loyalty benefits.
- Register and operate provider accounts.
- Manage listings, orders, finance, inventory, pricing, and business performance.
- Support users through profile, privacy, notifications, help center, direct messaging, and the Lumi planner assistant.

## Key Features

### Traveler Experience

- Home screen with destination search, travel categories, offers, and recommended destinations.
- Hotel and service search/filter flow.
- Service details, booking checkout, add-payment flow, and payment success screen.
- My Trips screen for booked travel services.
- Wallet and loyalty experience.
- Trip planner dashboard, timeline, new-trip form, and activity creation flow.
- Lumi Planner bottom-sheet assistant for itinerary, hotel, budget, and activity suggestions.
- Account flows for initial registration, profile, security, notifications, and help center.

### Provider Experience

- Provider onboarding and registration flows.
- Provider dashboard for operational entry points.
- Listing management, including list view, add listing, edit listing, and listing analytics.
- Order management, direct messaging, finance/payout, inventory, and pricing screens.
- Premium service flows such as VIP services and elite upgrade confirmation.

## Tech Stack

- Flutter with Dart `^3.9.2`.
- Material 3 design system.
- `go_router` for declarative navigation.
- `cupertino_icons` for optional iOS-style icons.
- `flutter_lints` for standard linting rules.
- Local UI state with `StatefulWidget` and `setState`.
- Mock/hardcoded data only; no backend or persistent storage is connected yet.

## Project Structure

```text
lib/
|-- constants/
|   |-- colors.dart          # Tripwise color palette
|   `-- theme.dart           # Shared Material 3 theme
|-- models/                  # Sample data models
|-- screens/                 # Main application screens
|-- services/                # Mock services and sample data
|-- widgets/                 # Shared top bars, taskbars, cards, and assistant UI
`-- main.dart                # App entry point and GoRouter configuration
```

Platform directories such as `android/`, `ios/`, `web/`, `macos/`, `linux/`, and `windows/` follow the standard Flutter scaffold.

## Getting Started

### Requirements

- Flutter SDK compatible with Dart `^3.9.2`.
- Android Studio, Xcode, Chrome, or another supported Flutter target.
- A physical device, emulator, simulator, web target, or desktop target.

### Install Dependencies

```bash
cd trip_wise
flutter pub get
```

### Run the App

```bash
flutter run
```

Run on web:

```bash
flutter run -d chrome
```

The app currently starts at:

```text
/register
```

## Common Commands

```bash
flutter pub get        # Install dependencies
flutter analyze        # Run static analysis and lint checks
flutter test           # Run tests
flutter run            # Start the app
flutter build web      # Build for web
flutter build apk      # Build Android APK
```

> Note: Some tests are still based on older template/demo flows and should be updated to match the real Tripwise UI.

## Navigation

Routes are defined in `lib/main.dart` with `GoRouter`.

| Route | Screen |
| --- | --- |
| `/register` | Initial registration |
| `/home` | Home |
| `/search_filter` | Hotel/service search and filters |
| `/service_details` | Service details |
| `/booking_checkout` | Booking checkout |
| `/payment_success` | Payment success |
| `/my_trips` | My Trips |
| `/wallet_loyalty` | Wallet and loyalty |
| `/trip_planner_dashboard` | Trip planner dashboard |
| `/trip_planner_timeline` | Trip itinerary timeline |
| `/plan_new_trip_form` | New trip planning form |
| `/profile_registration` | User profile |
| `/provider_registration` | Provider registration |
| `/provider_dashboard` | Provider dashboard |
| `/provider_listings` | Listing management |
| `/provider_listing_add` | Add listing |
| `/provider_listing_edit` | Edit listing |
| `/provider_analytics` | Listing analytics |
| `/order_manager` | Order management |
| `/direct_messaging` | Direct messaging |
| `/provider_finance` | Provider finance and payout |
| `/inventory_pricing` | Inventory and pricing |
| `/security_privacy` | Security and privacy |
| `/notifications` | Notifications |
| `/help_center` | Help center |

## Design System

Tripwise uses a centralized theme in `lib/constants/theme.dart` and a shared color palette in `lib/constants/colors.dart`.

Design principles:

- Material 3 with a mobile-first layout direction.
- Tripwise blue as the primary brand color and orange as the main accent color.
- Reusable shared components for top bars, bottom taskbars, cards, and the planner assistant.
- `Inter` is configured as the font family. Add font assets in `pubspec.yaml` if exact typography is required across every platform.

## Current Status

The project is currently a UI prototype. It is suitable for screen demos, navigation demos, and interaction review. Before production, the following areas still need to be completed:

- Backend APIs, authentication, and authorization.
- App-level state management such as Provider, Riverpod, or Bloc.
- Persistent storage for bookings, users, listings, and payments.
- Tests that match the real screens and user flows.
- Loading states, empty states, error handling, and async data flows.
- Localization, accessibility review, and image optimization.

## Suggested Next Steps

1. Replace template/demo tests with tests for `MyApp`, routing, and core flows.
2. Move mock data into a clearer repository/service layer.
3. Select the production state-management approach for booking and provider flows.
4. Connect APIs for search, booking, payment, messaging, and listing management.
5. Finalize brand assets, icons, fonts, and internal illustration/image assets.

## License

No license has been declared yet. Add a `LICENSE` file before publishing or distributing the project commercially.
