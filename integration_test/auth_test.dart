import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication UI Tests', () {

    testWidgets('Login screen shows email and password fields', (tester) async {
      await launchApp(tester);
      expect(find.byKey(const Key('emailField')),    findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')),   findsOneWidget);
    });

    testWidgets('Login shows error on wrong credentials', (tester) async {
      await launchApp(tester);
      await tester.enterText(
          find.byKey(const Key('emailField')),    'wrong@test.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'wrongpass');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('errorBanner')), findsOneWidget);
    });

    testWidgets('Login shows validation error on empty fields', (tester) async {
      await launchApp(tester);
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Navigate to Register screen', (tester) async {
      await launchApp(tester);
      // Ensure login button is visible before trying to tap register
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      await tester.tap(find.byKey(const Key('goToRegister')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('registerButton')), findsOneWidget);
      expect(find.byKey(const Key('usernameField')),  findsOneWidget);
    });

    testWidgets('Register shows validation on short username', (tester) async {
      await launchApp(tester);
      // Ensure login button is visible before trying to tap register
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      await tester.tap(find.byKey(const Key('goToRegister')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // Verify register screen is now visible
      expect(find.byKey(const Key('registerButton')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('usernameField')), 'ab');
      await tester.enterText(
          find.byKey(const Key('emailField')),    'user@test.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();

      expect(find.text('Minimum 3 characters'), findsOneWidget);
    });

    testWidgets('Register shows validation on short password', (tester) async {
      await launchApp(tester);
      // Ensure login button is visible before trying to tap register
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      await tester.tap(find.byKey(const Key('goToRegister')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // Verify register screen is now visible
      expect(find.byKey(const Key('registerButton')), findsOneWidget);

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
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });
  });
}