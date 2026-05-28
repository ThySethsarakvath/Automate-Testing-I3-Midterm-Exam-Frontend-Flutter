import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:midterm_exam_task2/main.dart' as app;

const _apiSettle    = Duration(seconds: 8);
const _localSettle  = Duration(seconds: 2);

String testEmail()    => 'ci${DateTime.now().millisecondsSinceEpoch}@test.com';
String testUsername() => 'ci${DateTime.now().millisecondsSinceEpoch}';
const testPassword    = 'password123';

/// Clear stored session so each test starts from login screen
Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> launchApp(WidgetTester tester) async {
  // Clear any leftover session from previous test
  await clearSession();

  app.main();

  // Pump through splash screen (1s delay + navigation)
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle(_localSettle);
}

Future<void> goToRegister(WidgetTester tester) async {
  final link = find.byKey(const Key('goToRegister'));
  if (tester.any(link)) {
    await tester.tap(link);
    await tester.pumpAndSettle(_localSettle);
  }
}

Future<void> registerAndLogin(WidgetTester tester) async {
  final email    = testEmail();
  final username = testUsername();

  await goToRegister(tester);

  await tester.enterText(find.byKey(const Key('usernameField')), username);
  await tester.pump();
  await tester.enterText(find.byKey(const Key('emailField')), email);
  await tester.pump();
  await tester.enterText(find.byKey(const Key('passwordField')), testPassword);
  await tester.pump();

  await tester.tap(find.byKey(const Key('registerButton')));

  // Wait for API response + navigation to feed
  await tester.pumpAndSettle(_apiSettle);
}