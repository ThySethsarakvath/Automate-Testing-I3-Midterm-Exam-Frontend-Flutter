import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Posts CRUD UI Tests', () {

    testWidgets('Feed screen loads with post list', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Either posts or empty message shown
      final hasPosts = tester.any(find.byKey(const Key('postsList')));
      final isEmpty  = tester.any(find.byKey(const Key('emptyFeed')));
      expect(hasPosts || isEmpty, isTrue);
    });

    testWidgets('Create Post — shows validation on empty title', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);
      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();

      // Submit without filling anything
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle();
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('Create Post — successfully creates and appears in feed',
        (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('titleField')),   'My Test Post');
      await tester.enterText(
          find.byKey(const Key('contentField')), 'This is my test content.');
      await tester.enterText(
          find.byKey(const Key('tagsField')),    'test, flutter');
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be back on feed with the new post
      expect(find.text('My Test Post'), findsOneWidget);
    });

    testWidgets('Edit Post — pre-fills fields and updates post', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      // Create post first
      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('titleField')),   'Original Title');
      await tester.enterText(
          find.byKey(const Key('contentField')), 'Original content here.');
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap edit on first post card's edit button
      final editButtons = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('editPost_'),
      );
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Verify pre-filled
      expect(find.text('Original Title'), findsOneWidget);

      // Update
      await tester.enterText(
          find.byKey(const Key('titleField')), 'Updated Title');
      await tester.tap(find.byKey(const Key('updatePostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Updated Title'), findsOneWidget);
    });

    testWidgets('Delete Post — removes post from feed', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      // Create a post
      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('titleField')),   'Post To Delete');
      await tester.enterText(
          find.byKey(const Key('contentField')), 'Will be deleted.');
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Post To Delete'), findsOneWidget);

      // Tap delete
      final deleteButtons = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('deletePost_'),
      );
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirm in dialog
      await tester.tap(find.byKey(const Key('confirmDelete')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Post To Delete'), findsNothing);
    });

    testWidgets('Like button toggles like on post', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('titleField')),   'Likeable Post');
      await tester.enterText(
          find.byKey(const Key('contentField')), 'Like me please!');
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final likeButtons = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('likeButton_'),
      );
      await tester.tap(likeButtons.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Like count should now be 1 — just verify no crash
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('Cancel delete dialog — post stays in feed', (tester) async {
      await launchApp(tester);
      await registerAndLogin(tester);

      await tester.tap(find.byKey(const Key('createPostFab')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('titleField')),   'Keep Me');
      await tester.enterText(
          find.byKey(const Key('contentField')), 'Do not delete.');
      await tester.tap(find.byKey(const Key('submitPostButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final deleteButtons = find.byWidgetPredicate(
        (w) => w is IconButton && w.key.toString().contains('deletePost_'),
      );
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.byKey(const Key('cancelDelete')));
      await tester.pumpAndSettle();

      expect(find.text('Keep Me'), findsOneWidget);
    });
  });
}