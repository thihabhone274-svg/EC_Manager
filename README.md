# EC Manager

An Android application for ECs to organise students, subjects, session orders, and payment records. Built with Flutter and a local SQLite database as the developer's first Flutter app.

**Status:** V1 learning project. Android is the developed target; iOS has not been developed or tested. This repository preserves the current application before a planned UI and workflow improvement.

## Features in the source

| Area | Functionality |
| --- | --- |
| Dashboard | Payment summaries and status filtering |
| Students | Student names and unique roll numbers |
| Subjects and sessions | Subject records, session amounts, and participating students |
| Orders | Session ordering and associated student records |
| Payments | Paid, unpaid, partial and overpaid states; carried amounts and payment methods |
| History and reports | Payment changes and reporting screens |
| Local storage | SQLite persistence with transactions and schema upgrades |

Payment methods such as Cash, Wave Pay, and KPay are record labels. The app does not integrate with payment gateways or transfer money.

## Learning context

This first Flutter project explores mobile interfaces, practical EC workflows, Dart models, local database operations, and payment calculations. The next development goals are clearer UI/UX, easier bulk payment entry, stronger tests, and a more maintainable code structure.

## Run on Android

Requirements:

- Flutter with a bundled Dart SDK satisfying `^3.12.1` from `pubspec.yaml`.
- Android SDK and a connected Android device or emulator.
- A compatible Java/Gradle environment. The project targets Java 17 and currently pins Android NDK `30.0.14904198` in `android/app/build.gradle.kts`.

```sh
git clone https://github.com/thihabhone274-svg/EC_Manager.git
cd EC_Manager
flutter doctor
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Replace `<android-device-id>` with the Android device ID shown by `flutter devices`. Android SDK paths are local to your computer; `android/local.properties` is deliberately excluded. Configure Flutter/Android Studio on your machine rather than copying another machine's paths.

The application creates its local database on first launch. It does not require Supabase, Firebase, or a separate SQL server. Internet access is needed to install development dependencies.

For a local debug APK:

```sh
flutter build apk --debug
```

The existing release configuration uses debug signing and an example application ID. It is not prepared for Play Store distribution.

## Try the workflow

1. Add fictional student records.
2. Create subjects and sessions/orders.
3. Select participating students where supported.
4. Record amounts and payment methods.
5. Review payment status, history, and report totals.
6. Restart the app to check that records persist.

Use fictional data when demonstrating the app or taking portfolio screenshots.

## Project structure

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | App entry point, models, SQLite helper, screens, and widgets |
| `android/` | Android platform code, resources, and Gradle configuration |
| `assets/logo.png` | Source image for launcher icon generation |
| `pubspec.yaml` | Dependencies and application configuration |
| `pubspec.lock` | Resolved dependency versions from the supplied project |
| `analysis_options.yaml` | Dart analysis configuration |

The current implementation is concentrated in `main.dart`. Splitting it into models, data services, screens, and reusable widgets is planned; this upload does not claim that refactor is complete.

## Verification and limitations

- Source and project configuration were inspected for this upload. Flutter and Dart were not installed in the preparation environment, so no build, analyzer, or device test was run here.
- The supplied `test` archive was empty. No automated test suite is included, and there are no claimed passing Flutter tests.
- Run `flutter analyze` locally and check payment calculations and database upgrades before relying on the app.
- Money is represented using `double`/SQLite `REAL`; rounding and a possible integer-based representation need review.
- Deleting parent records can cascade to related records. Review deletion prompts and history retention before using real records.
- The theme requests Poppins, but no bundled Poppins font or font declaration was supplied; a fallback font will be used.
- Cloud synchronisation and iOS support are not included.

## Planned improvements

- Simplify the six-destination bottom navigation and improve visual consistency.
- Design bulk payments across multiple students and subjects, including partial selections.
- Separate database code and shared widgets from screen code.
- Add tests for totals, partial payments, carry-forward behaviour, deletions, and migrations.
- Review backup/export and recovery needs for local payment records.

## Repository preparation

The upload excludes Gradle caches, machine-specific SDK paths, generated plugin registration, IDE files, and private database/signing files. Launcher icon configuration is Android-only. The original application workflow is preserved for subsequent improvements.
