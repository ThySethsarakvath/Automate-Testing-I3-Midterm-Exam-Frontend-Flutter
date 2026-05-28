import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

// Helper: create a post from the feed screen
Future<void> createPost(
  WidgetTester tester, {
  required String title,
  required String content,
  String tags = '',
}) async {
  await tester.tap(find.byKey(const Key('createPostFab')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  await tester.enterText(find.byKey(const Key('titleField')),   title);
  await tester.pump();
  await tester.enterText(find.byKey(const Key('contentField')), content);
  await tester.pump();
  if (tags.isNotEmpty) {
    await tester.enterText(find.byKey(const Key('tagsField')), tags);
    await tester.pump();
  }

  await tester.tap(find.byKey(const Key('submitPostButton')));
  await tester.pumpAndSettle(const Duration(seconds: 6));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Posts CRUD UI Tests', () {

    testWidgets('Feed screen loads after login', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      // Feed screen rendered (FAB visible is enough)
      expect(find.byKey(const Key('createPostFab')), findsOneWidget);
    });

    testWidgets('Create Post — shows validation on empty title', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Submit without title
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle();
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('Create Post — validates empty content', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
          find.byKey(const Key('titleField')), 'Some Title');
      await tester.pump();
      // Leave content empty
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle();
      expect(find.text('Content is required'), findsOneWidget);
    });

    testWidgets('Create Post — successfully creates and appears in feed',
        (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await createPost(tester,
          title:   'My CI Post',
          content: 'Created in GitHub Actions',
          tags:    'ci, flutter');
      expect(find.text('My CI Post'), findsOneWidget);
    });

    testWidgets('Delete Post — cancel keeps post in feed', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await createPost(tester,
          title:   'Do Not Delete Me',
          content: 'This should stay.');

      // Tap delete icon
      final deleteBtn = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('deletePost_'),
      );
      expect(deleteBtn, findsWidgets);
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();

      // Cancel the dialog
      await tester.tap(find.byKey(const Key('cancelDelete')));
      await tester.pumpAndSettle();

      expect(find.text('Do Not Delete Me'), findsOneWidget);
    });

    testWidgets('Delete Post — confirm removes post from feed', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await createPost(tester,
          title:   'Delete This Post',
          content: 'Goodbye world.');

      expect(find.text('Delete This Post'), findsOneWidget);

      final deleteBtn = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('deletePost_'),
      );
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirmDelete')));
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.text('Delete This Post'), findsNothing);
    });

    testWidgets('Edit Post — pre-fills title and updates', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await createPost(tester,
          title:   'Original Title',
          content: 'Original content.');

      final editBtn = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('editPost_'),
      );
      await tester.tap(editBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Title field should be pre-filled
      expect(find.text('Original Title'), findsOneWidget);

      // Clear and type new title
      await tester.enterText(
          find.byKey(const Key('titleField')), 'Updated Title');
      await tester.pump();
      await tester.tap(find.byKey(const Key('updatePostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.text('Updated Title'), findsOneWidget);
    });

    testWidgets('Like button — can tap without crash', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await createPost(tester,
          title:   'Likeable Post',
          content: 'Please like me.');

      final likeBtn = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('likeButton_'),
      );
      expect(likeBtn, findsWidgets);
      await tester.tap(likeBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      // No crash = pass
      expect(find.byKey(const Key('createPostFab')), findsOneWidget);
    });
  });
}