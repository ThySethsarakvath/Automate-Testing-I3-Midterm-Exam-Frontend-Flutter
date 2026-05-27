# Contributing Guide

Thank you for considering contributing to the Social Media App! This guide will help you get started.

## Table of Contents

- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Code Style](#code-style)
- [Testing Requirements](#testing-requirements)

## Development Setup

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd midterm_exam_task2

# Get dependencies
flutter pub get

# Verify setup
flutter doctor
```

### 2. Run the App Locally

```bash
# Start backend API
cd ../backend  # if you have backend locally
npm start

# Run Flutter app
flutter run

# Or on specific device
flutter run -d emulator-5554
```

### 3. Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/ -d emulator-5554

# With coverage
flutter test --coverage
```

## Making Changes

### 1. Create a Feature Branch

```bash
# Create branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# For bugs use:
git checkout -b bugfix/bug-name

# For documentation use:
git checkout -b docs/doc-name
```

### 2. Make Your Changes

```bash
# Edit files as needed
# Test your changes
flutter run

# Run tests
flutter test
flutter test integration_test/ -d emulator-5554
```

### 3. Format and Analyze

```bash
# Format code
dart format lib/ test/ integration_test/

# Analyze for issues
flutter analyze

# Fix issues automatically (if possible)
flutter fix
```

### 4. Commit Changes

```bash
# Stage changes
git add .

# Commit with conventional commit message
git commit -m "feat: Add user profile screen"

# View changes
git log

# Push to remote
git push origin feature/your-feature-name
```

## Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/):

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, semicolons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process, dependencies, etc.

### Examples

```bash
# Feature
git commit -m "feat: Add dark mode support"

# Bug fix
git commit -m "fix: Prevent null pointer in post service"

# Documentation
git commit -m "docs: Update README with API documentation"

# With scope
git commit -m "feat(auth): Add two-factor authentication"

# With body and footer
git commit -m "feat(posts): Add ability to edit posts

- Allow users to edit own posts
- Add edit timestamp to post model
- Validate edit permissions

Closes #123"
```

## Pull Request Process

### 1. Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create PR on GitHub
# Title: "Feature: Add user profile screen"
# Description: Explain what and why
```

### 2. PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Tested locally

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
```

### 3. Automated Checks

The following checks must pass:
- ✅ Code formatting (dart format)
- ✅ Code analysis (flutter analyze)
- ✅ Unit tests (flutter test)
- ✅ Integration tests (flutter test integration_test/)

### 4. Code Review

- Address review comments
- Push updates to same branch
- React to comments when done

### 5. Merge

Once approved:
```bash
# Merge via GitHub UI (squash or rebase)
# Or locally:
git checkout develop
git pull origin develop
git merge feature/your-feature-name
git push origin develop

# Delete branch
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
```

## Code Style

### Dart Style Guide

Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

### Key Points

```dart
// Class names: PascalCase
class UserProvider extends ChangeNotifier { }

// Method/variable names: camelCase
void fetchUserProfile() { }
var userName = 'John';

// Constants: lowerCamelCase
const defaultTimeout = Duration(seconds: 30);

// Private members: _camelCase
var _privateField = 'private';
void _privateMethod() { }

// File names: snake_case
// user_provider.dart
// auth_service.dart

// Imports: Organize in groups
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
```

### Code Organization

```dart
class AuthProvider extends ChangeNotifier {
  // 1. Static constants
  static const String tag = 'AuthProvider';

  // 2. Instance variables
  final AuthService _authService = AuthService();
  User? _user;

  // 3. Getters
  User? get user => _user;
  bool get isLoggedIn => _token != null;

  // 4. Lifecycle methods
  @override
  void dispose() {
    super.dispose();
  }

  // 5. Public methods
  Future<bool> login({required String email}) async {
    // Implementation
  }

  // 6. Private methods
  void _setLoading(bool value) {
    // Implementation
  }
}
```

## Testing Requirements

### Unit Tests

```dart
// test/auth_service_test.dart
void main() {
  group('AuthService', () {
    test('login returns user token', () async {
      // Arrange
      final authService = AuthService();
      
      // Act
      final result = await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      // Assert
      expect(result['success'], true);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/auth_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can login', (tester) async {
    await launchApp(tester);
    
    await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    
    expect(find.byKey(Key('feedScreen')), findsOneWidget);
  });
}
```

### Test Coverage Goals

- Unit test coverage: **>80%**
- Integration tests: **Key user flows**
- Null safety: **100%**

## Documentation Standards

### Comments

```dart
/// Documentation comment - appears in IDE autocomplete
/// 
/// Use for public APIs
int calculateSum(int a, int b) => a + b;

// Regular comment
// Use for implementation details

/* Multi-line comment */
```

### Examples

```dart
/// Authenticates a user with email and password.
/// 
/// Returns a [Future] that completes with [true] if successful,
/// [false] otherwise.
/// 
/// Example:
/// ```dart
/// final success = await authService.login(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
Future<bool> login({
  required String email,
  required String password,
}) async {
  // Implementation
}
```

## Performance Considerations

### Tips

1. **Use const constructors** when possible
   ```dart
   // ✅ Good
   const SizedBox(height: 16)
   
   // ❌ Avoid
   SizedBox(height: 16)
   ```

2. **Cache expensive computations**
   ```dart
   final expensiveValue = _computeExpensiveValue();
   ```

3. **Use Provider selectors**
   ```dart
   // ✅ Good - rebuilds only when needed
   Selector<AuthProvider, String?>(
     selector: (_, auth) => auth.token,
     builder: (_, token, __) => Text(token ?? ''),
   )
   
   // ❌ Avoid - rebuilds on any change
   Consumer<AuthProvider>(
     builder: (_, auth, __) => Text(auth.token ?? ''),
   )
   ```

## Reporting Issues

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Flutter version: `flutter --version`
- Device/Emulator: Device name
- Backend: URL/Version

## Logs/Screenshots
Attach error logs and screenshots
```

## Questions?

- Check README.md
- Check existing issues and PRs
- Review code style guide
- Ask in discussions

---

Thank you for contributing! 🎉
