import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication UI Tests', () {

    // Clear session before every test in this group
    setUp(() async => clearSession());

    testWidgets('Login screen shows required fields', (tester) async {
      await launchApp(tester);
      expect(find.byKey(const Key('emailField')),    findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')),   findsOneWidget);
    });

    testWidgets('Login shows validation error on empty submit', (tester) async {
      await launchApp(tester);
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Login shows validation error on invalid email', (tester) async {
      await launchApp(tester);
      await tester.enterText(
          find.byKey(const Key('emailField')), 'not-an-email');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Login shows error banner on wrong credentials', (tester) async {
      await launchApp(tester);
      await tester.enterText(
          find.byKey(const Key('emailField')),    'nobody@test.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'wrongpassword');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 8));
      expect(find.byKey(const Key('errorBanner')), findsOneWidget);
    });

    testWidgets('Navigate to Register screen', (tester) async {
      await launchApp(tester);
      await tester.tap(find.byKey(const Key('goToRegister')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('registerButton')), findsOneWidget);
      expect(find.byKey(const Key('usernameField')),  findsOneWidget);
    });

    testWidgets('Register shows validation on short username', (tester) async {
      await launchApp(tester);
      await goToRegister(tester);
      await tester.enterText(find.byKey(const Key('usernameField')), 'ab');
      await tester.enterText(
          find.byKey(const Key('emailField')),    'u@test.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();
      expect(find.text('Minimum 3 characters'), findsOneWidget);
    });

    testWidgets('Register shows validation on short password', (tester) async {
      await launchApp(tester);
      await goToRegister(tester);
      await tester.enterText(
          find.byKey(const Key('usernameField')), 'validuser');
      await tester.enterText(
          find.byKey(const Key('emailField')),    'valid@test.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), '123');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();
      expect(find.text('Minimum 6 characters'), findsOneWidget);
    });

    testWidgets('Successful registration navigates to feed', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      expect(find.byKey(const Key('createPostFab')), findsOneWidget);
    });

    testWidgets('Logout returns to login screen', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });
  });
}