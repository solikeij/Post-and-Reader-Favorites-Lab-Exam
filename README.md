# Post Reader & Favorites

A Flutter reading app for the ITP107 finals laboratory project. Browse JSONPlaceholder posts, open a full article, and keep a local collection with personal notes.

## Requirements and features
- Part 1: exactly three named routes (`/`, `/details`, `/favorites`), map arguments, explicit back actions.
- Part 2: timed GET, JSON decoding, loading/error/retry/empty states, pull-to-refresh; validated POST dialog with progress and visible results.
- Part 3: Hive map CRUD keyed by post ID, duplicate protection, 100-character notes, confirmed icon deletion, swipe deletion, and undo restoring the note.
- Design: a single Material 3 midnight-navy and cyan theme, shared spacing, gradient reading headers, charcoal cards, pill-shaped actions, scrollable layouts and a constrained reading column.
- JSONPlaceholder simulates POST writes. Successful submissions appear newest-first in a separate Created this session list, including when the server feed is empty or fails. They remain across refreshes until the app restarts; the screen scrolls to the newest result.
- Favorites persist locally without clearing the box on startup. Web storage belongs to the browser origin/profile; use the same port and do not clear site data.

## Packages
Runtime dependencies: Flutter SDK, http, hive, hive_flutter only. Testing uses flutter_test and linting uses flutter_lints. No generators, adapters, external fonts or image assets are required.

## Run
Developed with Flutter 3.27.3 / Dart 3.6.1 (stable).
```powershell
cd "C:\Users\Admin\Desktop\DeMatta&Malana Labexam"
flutter pub get
flutter run -d chrome --web-port 8080
# Or connect an Android device/start an emulator:
flutter run
```
Android's main manifest includes INTERNET permission. Accept Android SDK licenses interactively with `flutter doctor --android-licenses` if required. Windows desktop requires Developer Mode for plugin symlinks. The installed Java 21 needs a compatible Gradle wrapper; this project uses Gradle 8.7.

## Verify
```powershell
dart format lib test
flutter analyze
flutter test
flutter build web
```
Automated tests cover routes and arguments, GET error/retry, POST validation/success/failure, Hive CRUD, duplicate note preservation, disk close/reopen, delete and undo. Device force-stop/reopen and airplane-mode checks remain part of the recording procedure in [SCREENSHOT_SCRIPT.md](SCREENSHOT_SCRIPT.md).

## Folder structure
```
lib/
  main.dart
  app.dart
  constants/app_routes.dart
  constants/app_theme.dart
  models/post.dart
  services/post_api_service.dart
  services/favorites_service.dart
  screens/posts_screen.dart
  screens/post_details_screen.dart
  screens/favorites_screen.dart
  widgets/reader_widgets.dart
  widgets/new_post_dialog.dart
test/widget_test.dart
android/app/src/main/AndroidManifest.xml
```
The requested structure is preserved; widgets/ contains reusable layout and a dialog with its own controller lifecycle.

## Screenshots to capture
1. Loaded posts list.
2. Selected post details.
3. POST dialog, validation, success result and failure message.
4. Favorites after add, note edit, deletion and undo.
5. Favorites and note after fully closing/reopening.
Follow [SCREENSHOT_SCRIPT.md](SCREENSHOT_SCRIPT.md) in order.

## Submission
The prompt specifies `ITP107_FinalsLabExam_BSIT3B_Malana.zip`; confirm the section and surname before submission. Fill the original examination PDF with the correct student number, section and GitHub URL. Prompt-provided name: Malana, Patrick Kru S.; professor: Prof. Albert Q. Alforja. Leave score blank. The form and real device evidence require the student's information and recording.

Run `./package_project.ps1` from this folder to create a source ZIP in the parent directory, excluding generated output, local SDK paths, IDE settings and Git data.

To publish to a repository you own:
```powershell
git init
git add .
git commit -m "Build Post Reader and Favorites"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ITP107_FinalsLabExam_BSIT3B_Malana.git
git push -u origin main
```

## Code walkthrough
main opens Hive before the app starts. PostApiService owns timed requests; screens branch on statuses and render results. Post.toMap supplies route arguments; details reads ModalRoute in build. FavoritesService uses integer IDs so repeated saves cannot duplicate a post; Map<String,dynamic>.from converts Hive's dynamically typed maps. ValueListenableBuilder reflects writes immediately.

## Official references
- [Flutter HTTP recipe](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Named route arguments](https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments)
- [Hive Flutter](https://pub.dev/packages/hive_flutter)
- [HTTP](https://pub.dev/packages/http)
