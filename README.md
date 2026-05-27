# Social Media App - Flutter Frontend

A Flutter mobile application for a social media platform. This app provides user authentication, post creation, feed viewing, and post management features integrated with a NestJS backend API.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)
- [Building for Production](#building-for-production)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

This Flutter application implements a social media interface with the following features:

- **User Authentication**: Register, login, and logout functionality
- **Post Management**: Create, view, edit, and delete posts
- **Feed Display**: Browse posts from other users
- **User Profile**: View user information and posts
- **State Management**: Uses Provider for reactive state management

**Technology Stack:**
- Flutter 3.11.1+
- Provider (State Management)
- GoRouter (Navigation)
- HTTP (API Requests)
- Shared Preferences (Local Storage)

---

## Project Structure

```
lib/
├── main.dart                    # App entry point and router configuration
├── config/
│   └── api_config.dart         # API endpoints configuration
├── models/
│   ├── user.dart               # User model
│   └── post.dart               # Post model
├── providers/
│   ├── auth_provider.dart      # Authentication state management
│   └── post_provider.dart      # Posts state management
├── services/
│   ├── auth_service.dart       # Authentication API calls
│   └── post_service.dart       # Posts API calls
└── screens/
    ├── splash_screen.dart      # Splash/Loading screen
    ├── auth/
    │   ├── login_screen.dart   # Login UI
    │   └── register_screen.dart# Registration UI
    └── posts/
        ├── feed_screen.dart    # Feed list view
        ├── post_detail_screen.dart  # Single post view
        ├── create_post_screen.dart  # Create new post
        └── edit_post_screen.dart    # Edit existing post

integration_test/
├── auth_test.dart              # Authentication integration tests
├── posts_test.dart             # Posts integration tests
├── app_test.dart               # General app flow tests
└── helpers/
    └── test_helper.dart        # Test utilities and helpers

test/
├── auth_service_test.dart      # Unit tests for auth service
└── post_service_test.dart      # Unit tests for post service
```

---

## Prerequisites

Before you start, ensure you have the following installed:

### Required:
- **Flutter SDK**: 3.11.1 or higher
  - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Comes with Flutter (3.11.1+)
- **Git**: For version control

### For Android Development:
- **Android Studio** or **Android SDK Tools**
- **Android Emulator** or physical Android device (API 21+)
- Minimum 3GB free disk space

### For iOS Development (macOS only):
- **Xcode** 14.0 or higher
- **CocoaPods**
- Minimum 5GB free disk space

### Backend API:
- NestJS backend running on `http://localhost:3000` (local development)
- Or update `lib/config/api_config.dart` with your backend URL

---

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd midterm_exam_task2
```

### 2. Get Flutter Packages

```bash
flutter pub get
```

### 3. Verify Flutter Setup

```bash
flutter doctor
```

Ensure all required components show a checkmark (✓). Fix any issues before proceeding.

---

## Configuration

### API Configuration

The app connects to a backend API. Configure the endpoint in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // For Android Emulator (default)
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // For physical device, replace with your machine's IP:
  // static const String baseUrl = 'http://192.168.1.X:3000';
  
  static const String register = '$baseUrl/auth/register';
  static const String login    = '$baseUrl/auth/login';
  static const String posts    = '$baseUrl/posts';
  static const String feed     = '$baseUrl/posts/feed';
  static const String users    = '$baseUrl/users';
  static const String me       = '$baseUrl/users/me';
}
```

**Important:**
- For **Android Emulator**: Use `10.0.2.2` (special address to reach host machine)
- For **Physical Device**: Use your computer's actual IP address (e.g., `192.168.1.100`)
- For **iOS Simulator**: Use `localhost` or `127.0.0.1`

---

## Running the App

### Prerequisites for Running
- Backend API must be running
- Android Emulator/device or iOS Simulator must be configured

### Android

#### Using Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator-id>

# Run app on emulator
flutter run
```

#### Using Physical Device

1. Enable USB Debugging on your Android device
2. Connect device via USB
3. Run:
   ```bash
   flutter run
   ```

### iOS (macOS only)

```bash
# Install iOS pods
cd ios
pod install
cd ..

# Run on iOS Simulator
flutter run

# Or run on physical device
flutter run -d <device-id>
```

### Web (Experimental)

```bash
flutter run -d chrome
```

### Common Run Options

```bash
# Run in debug mode (default)
flutter run

# Run in release mode (optimized)
flutter run --release

# Run on specific device
flutter run -d <device-id>

# Run and pause on app start (for debugging)
flutter run --start-paused

# Run with verbose logging
flutter run -v
```

---

## Running Tests

### Unit Tests

Run tests for services:

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### Integration Tests

Run full app integration tests (requires emulator/device):

```bash
# Run all integration tests
flutter test integration_test/

# Run specific integration test
flutter test integration_test/auth_test.dart -d <device-id>

# Run on Android emulator
flutter test integration_test/auth_test.dart -d emulator-5554

# Run with verbose output
flutter test integration_test/auth_test.dart -d <device-id> -v

# Run specific test case
flutter test integration_test/auth_test.dart --plain-name "Login screen shows email and password fields" -d <device-id>
```

### Test Coverage

Generate coverage report:

```bash
# Generate coverage data
flutter test --coverage

# View coverage report (requires lcov on Linux/macOS)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Building for Production

### Android

#### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Build App Bundle (for Google Play)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)

#### Build IPA

```bash
# Release build
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

### Web

```bash
flutter build web --release

# Output: build/web/
```

---

## Troubleshooting

### Common Issues

#### 1. "Connection refused" Error

**Problem**: `Connection refused, errno = 111` when trying to login/register

**Solutions**:
- Verify backend API is running on the correct port
- Check API URL in `lib/config/api_config.dart`:
  - Android Emulator: Use `10.0.2.2:3000` (not `localhost`)
  - Physical Device: Use your machine's IP address
  - iOS: Can use `localhost:3000`

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// Physical Device - Get IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String baseUrl = 'http://192.168.1.100:3000';
```

#### 2. "Found 0 widgets" in Tests

**Problem**: Integration tests fail finding widgets like `goToRegister`

**Solutions**:
- Ensure emulator/device is connected: `flutter devices`
- Clear app data: `adb shell pm clear com.example.midterm_exam_task2`
- Rebuild: `flutter clean && flutter pub get`
- Increase wait times in tests if device is slow

#### 3. Private Member Access Error

**Problem**: `'_authService' is private and cannot be accessed`

**Solution**: Use the public getter instead:
```dart
// ❌ Wrong
auth._authService.getToken

// ✅ Correct
auth.authService.getToken
```

#### 4. Splash Screen Redirect Not Working

**Problem**: After login/register, app redirects back to login

**Solutions**:
- Add delay before navigation:
  ```dart
  if (ok && mounted) {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) context.go('/feed');
  }
  ```
- Ensure token is properly saved in SharedPreferences
- Check GoRouter redirect logic is correct

#### 5. "No active route found" Error

**Problem**: Navigation to a route that doesn't exist

**Solutions**:
- Verify route path in `GoRouter` routes list
- Check for typos in route paths
- Ensure route is defined in `main.dart`

#### 6. Build Failures

**Clean and rebuild**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

**For persistent issues**:
```bash
# Remove build artifacts
rm -rf build/
rm -rf ios/Pods ios/Podfile.lock
rm -rf .dart_tool/

# Fresh build
flutter pub get
flutter run
```

---

## Development Workflow

### 1. Start Backend API

```bash
# In your backend project directory
npm install
npm start
```

### 2. Configure API URL

Edit `lib/config/api_config.dart` with your backend's URL.

### 3. Launch Flutter App

```bash
flutter run
```

### 4. Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/ -d <device-id>
```

### 5. Build Release

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## API Integration Notes

### Authentication Flow

1. **Register**: POST `/auth/register` with username, email, password
2. **Login**: POST `/auth/login` with email, password
3. **Token Storage**: Token saved in `SharedPreferences`
4. **API Requests**: Token sent in Authorization header

### Expected API Response Format

**Registration Success (201)**:
```json
{
  "message": "Registration successful",
  "accessToken": "eyJhbGc...",
  "user": {
    "id": "uuid",
    "username": "john_doe",
    "email": "john@example.com",
    "createdAt": "2026-05-27T02:26:26.075Z"
  }
}
```

**Login Success (200)**:
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGc...",
  "user": { ... }
}
```

---

## Useful Commands

```bash
# Get all available devices
flutter devices

# Check environment setup
flutter doctor -v

# Format code
dart format lib/ test/ integration_test/

# Analyze code
flutter analyze

# Check dependencies for updates
flutter pub outdated

# Upgrade all dependencies
flutter pub upgrade

# Run specific device
flutter run -d <device-id>

# Kill all running emulators
adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
```

---

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Create a Pull Request

---

## License

This project is licensed under the MIT License.

---

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Flutter documentation: https://flutter.dev/docs
3. Check backend API documentation
4. Open an issue on GitHub

---

**Last Updated**: May 27, 2026
**Flutter Version**: 3.11.1+
**Dart Version**: Included with Flutter
