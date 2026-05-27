import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:midterm_exam_task2/main.dart' as app;

// Unique credentials per test run to avoid conflicts
String testEmail()    => 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
String testUsername() => 'user_${DateTime.now().millisecondsSinceEpoch}';
const  testPassword   = 'password123';

Future<void> launchApp(WidgetTester tester) async {
  // Clear SharedPreferences to start fresh
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  app.main();
  // Wait for splash screen (1 second) + navigation to login
  await tester.pumpAndSettle(const Duration(seconds: 3));
  // Extra pump to ensure login screen is fully rendered
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> registerAndLogin(
  WidgetTester tester, {
  String? email,
  String? username,
  String? password,
}) async {
  final e = email    ?? testEmail();
  final u = username ?? testUsername();
  final p = password ?? testPassword;

  // Go to register if on login screen
  final registerLink = find.byKey(const Key('goToRegister'));
  if (tester.any(registerLink)) {
    await tester.tap(registerLink);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  await tester.enterText(find.byKey(const Key('usernameField')), u);
  await tester.enterText(find.byKey(const Key('emailField')),    e);
  await tester.enterText(find.byKey(const Key('passwordField')), p);
  await tester.tap(find.byKey(const Key('registerButton')));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}