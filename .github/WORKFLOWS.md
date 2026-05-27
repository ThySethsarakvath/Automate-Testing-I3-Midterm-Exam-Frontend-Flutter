# GitHub Actions Workflows Documentation

This document explains all the automated workflows configured for this Flutter project.

## Overview

The project includes 5 GitHub Actions workflows that handle:
- Code quality and linting
- Unit and integration testing
- Building for Android, iOS, and Web
- Dependency checks
- Release management

## Workflows

### 1. CI Workflow (`ci.yml`)

**Trigger**: Push to `main`/`develop`, Pull Requests

**Purpose**: Continuous Integration - Analyze code, run tests, and build artifacts

**Jobs**:

#### a. Analyze and Format Check
```
- Analyzes Dart code for issues
- Checks code formatting
- Runs flutter analyze
```

#### b. Unit Tests
```
- Runs all unit tests
- Generates code coverage reports
- Uploads coverage to Codecov
```

#### c. Build Android APK
```
- Builds release APK
- Uploads artifact (7-day retention)
```

#### d. Build Web
```
- Builds web release
- Uploads artifact (7-day retention)
```

#### e. Build iOS
```
- Builds iOS release (requires macOS)
- Uploads artifact (7-day retention)
```

**How to use**:
```bash
# Automatically triggered on push
git push origin main

# View workflow progress
# GitHub UI > Actions > CI
```

### 2. Integration Tests Workflow (`integration_tests.yml`)

**Trigger**: Push to `main`/`develop`, Pull Requests

**Purpose**: Test the app on real Android and iOS emulators

**Jobs**:

#### a. Android Integration Tests
```
- Tests on API Level 28 and 31
- Uses Android Emulator Runner
- Tests authentication flow
```

#### b. iOS Integration Tests
```
- Tests on iPhone 14 simulator
- Tests authentication flow
- Continues on error to prevent blocking CI
```

**How to use**:
```bash
# Automatically triggered on push
git push origin develop

# Watch tests run on:
# GitHub UI > Actions > Integration Tests
```

**Environment Setup**:
- macOS runner used for both (has iOS tools)
- Emulator auto-starts and runs tests
- Results uploaded as artifacts

### 3. Code Quality Workflow (`code_quality.yml`)

**Trigger**: Push to `main`/`develop`, Pull Requests

**Purpose**: Enforce code quality standards and check dependencies

**Jobs**:

#### a. Lint and Static Analysis
```
- Dart format check
- Flutter analyze (no fatal infos)
- Unused file detection
```

#### b. Dependency Check
```
- Lists outdated packages
- Validates pubspec.yaml
- Checks for deprecated dependencies
```

**How to use**:
```bash
# Run locally first
flutter analyze
dart format lib/ test/ integration_test/

# Then push
git push origin develop
```

**Fixing Issues**:
```bash
# Fix formatting
dart format --fix lib/ test/ integration_test/

# Check what analyze found
flutter analyze

# Update dependencies
flutter pub upgrade
```

### 4. Release Workflow (`release.yml`)

**Trigger**: Tag push (e.g., `v1.0.0`) or manual workflow dispatch

**Purpose**: Create releases and build artifacts for distribution

**Jobs**:

#### a. Create GitHub Release
```
- Creates release on GitHub
- Auto-generates changelog
- Uploads to Releases page
```

#### b. Build and Upload Artifacts
```
- Builds APK release
- Builds App Bundle (for Play Store)
- Uploads to release page
```

#### c. Deploy to Google Play (Disabled by default)
```
- Requires: PLAY_STORE_SERVICE_ACCOUNT_JSON secret
- Uploads to internal testing track
```

#### d. Deploy to App Store (Disabled by default)
```
- Requires: fastlane setup + Apple credentials
- Uploads to App Store Connect
```

**How to use**:

**Creating a Release**:
```bash
# Tag your release
git tag v1.0.0
git push origin v1.0.0

# Or trigger manually
# GitHub UI > Actions > Release > Run workflow > Enter version
```

**Enable Play Store Deployment**:
1. Create service account at Google Cloud Console
2. Add secret: `PLAY_STORE_SERVICE_ACCOUNT_JSON`
3. Change `if: false` to `if: true` in release.yml
4. Push release tag

**Enable App Store Deployment**:
1. Setup fastlane in `ios/` directory
2. Configure Apple credentials
3. Change `if: false` to `if: true` in release.yml
4. Push release tag

## Setup and Configuration

### GitHub Secrets Required

Add these secrets to your repository: `Settings > Secrets and variables > Actions`

```
# For Play Store deployment (optional)
PLAY_STORE_SERVICE_ACCOUNT_JSON    # Base64 encoded service account JSON
ANDROID_KEYSTORE_BASE64            # Base64 encoded keystore
ANDROID_KEYSTORE_PASSWORD          # Keystore password
ANDROID_KEY_PASSWORD               # Key password

# For App Store deployment (optional)
APP_STORE_CONNECT_KEY_ID           # App Store Connect key ID
APP_STORE_CONNECT_ISSUER_ID        # App Store Connect issuer ID
APP_STORE_CONNECT_KEY_BASE64       # Base64 encoded key file
```

### Backend Configuration for Tests

The workflows use the same configuration as your app. Ensure:

1. **API URL** is correctly set in `lib/config/api_config.dart`
2. **Backend API** should be mocked or accessible during tests
3. **Test credentials** should be unique to avoid conflicts

For integration tests, update `test_helper.dart`:
```dart
String testEmail()    => 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
String testUsername() => 'user_${DateTime.now().millisecondsSinceEpoch}';
const  testPassword   = 'password123';
```

## Monitoring Workflows

### View Workflow Status
```
GitHub UI > Actions > [Workflow Name]
```

### Check Build Artifacts
```
GitHub UI > Actions > [Workflow Run] > Artifacts
```

### View Coverage Reports
```
GitHub UI > Actions > CI > unit_tests > Codecov link
```

## Troubleshooting

### Workflow Fails with "Flutter not found"
```yaml
# Ensure this step exists:
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.11.1'
```

### Android Build Fails
```bash
# Locally verify
flutter clean
flutter pub get
flutter build apk --release
```

### Integration Tests Timeout
- Increase timeout: `timeout-minutes: 30` in workflow
- Check emulator is running correctly
- Verify backend is accessible

### Code Format Check Fails
```bash
# Fix locally
dart format --fix lib/ test/ integration_test/
git add .
git commit -m "Format code"
git push
```

## Best Practices

### 1. Commit Guidelines
```bash
# Write descriptive commit messages
git commit -m "feat: Add user profile screen"

# Use conventional commits for auto-changelog
# feat: new feature
# fix: bug fix
# docs: documentation
# style: formatting
# refactor: code restructure
# perf: performance improvement
# test: test updates
```

### 2. Branch Strategy
```bash
# Create feature branches
git checkout -b feature/user-profile

# Push for PR
git push origin feature/user-profile

# Create PR on GitHub (triggers CI)
```

### 3. Release Process
```bash
# 1. Update version in pubspec.yaml
# 2. Create tag
git tag v1.0.0 -m "Release version 1.0.0"

# 3. Push tag
git push origin v1.0.0

# 4. Monitor release workflow
# GitHub UI > Actions > Release
```

### 4. Testing Before Release
```bash
# Run all tests locally
flutter test                                    # unit tests
flutter test integration_test/ -d emulator-5554 # integration tests

# Build release
flutter build apk --release
flutter build appbundle --release

# Only then tag and push
git tag v1.0.0
git push origin v1.0.0
```

## Performance Tips

### Reduce Build Time
```yaml
# Only build what's needed
- run: flutter build apk --release
  # For Android only

# Cache dependencies
- uses: actions/cache@v3
  with:
    path: ~/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
```

### Parallel Jobs
The CI workflow runs multiple jobs in parallel:
- analyze
- unit_tests
- build_android
- build_web
- build_ios

This speeds up the overall pipeline.

## Integration with Other Tools

### SonarQube
```yaml
- name: SonarQube Scan
  uses: SonarSource/sonarcloud-github-action@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Firebase Crash Reporting
```yaml
# Add firebase_crashlytics dependency
# Configure in main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

### Sentry
```dart
// Add sentry dependency
// Initialize in main.dart
await SentryFlutter.init((options) {
  options.dsn = 'https://YOUR-SENTRY-DSN';
});
```

## Disabling Workflows

To temporarily disable a workflow:

```yaml
# In the workflow file, change the trigger:
on:
  # Commented out to disable
  # push:
  #   branches: [ main ]
  workflow_dispatch:  # Keep manual trigger
```

Or disable from GitHub UI:
```
Settings > Actions > General > Disable all workflows
```

## More Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://flutter.dev/docs/deployment/cd)
- [Android Build Guide](https://flutter.dev/docs/deployment/android)
- [iOS Build Guide](https://flutter.dev/docs/deployment/ios)

---

**Last Updated**: May 27, 2026
