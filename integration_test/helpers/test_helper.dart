import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_exam_task2/main.dart' as app;

const _settle = Duration(seconds: 5);

String testEmail()    => 'ci_${DateTime.now().millisecondsSinceEpoch}@test.com';
String testUsername() => 'ci_${DateTime.now().millisecondsSinceEpoch}';
const testPassword    = 'password123';

Future<void> launchApp(WidgetTester tester) async {
  app.main();
  // Pump through the splash screen (it has a 1s delay + navigation)
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle(_settle);
}

Future<void> goToRegister(WidgetTester tester) async {
  final link = find.byKey(const Key('goToRegister'));
  if (tester.any(link)) {
    await tester.tap(link);
    await tester.pumpAndSettle(_settle);
  }
}

Future<void> registerAndLogin(
  WidgetTester tester, {
  String? email,
  String? username,
}) async {
  final e = email    ?? testEmail();
  final u = username ?? testUsername();

  await goToRegister(tester);

  await tester.enterText(find.byKey(const Key('usernameField')), u);
  await tester.pump();
  await tester.enterText(find.byKey(const Key('emailField')), e);
  await tester.pump();
  await tester.enterText(find.byKey(const Key('passwordField')), testPassword);
  await tester.pump();

  await tester.tap(find.byKey(const Key('registerButton')));
  // Wait for API call + navigation to feed
  await tester.pumpAndSettle(const Duration(seconds: 8));
}