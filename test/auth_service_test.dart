import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_exam_task2/models/user.dart';
import 'package:midterm_exam_task2/models/post.dart';

void main() {
  group('User model', () {
    test('fromJson parses correctly', () {
      final user = User.fromJson({
        'id': '123',
        'username': 'alice',
        'email': 'alice@test.com',
        'bio': 'Hello',
        'avatarUrl': '',
      });
      expect(user.id, '123');
      expect(user.username, 'alice');
      expect(user.email, 'alice@test.com');
      expect(user.bio, 'Hello');
    });

    test('fromJson handles missing optional fields', () {
      final user = User.fromJson({'id': '1', 'username': 'bob', 'email': 'b@b.com'});
      expect(user.bio, '');
      expect(user.avatarUrl, '');
    });
  });

  group('Post model', () {
    test('fromJson parses correctly', () {
      final post = Post.fromJson({
        'id': 'p1',
        'authorId': 'u1',
        'authorUsername': 'alice',
        'title': 'Hello',
        'content': 'World',
        'tags': ['a', 'b'],
        'likes': ['u2'],
        'comments': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
      });
      expect(post.title, 'Hello');
      expect(post.tags, ['a', 'b']);
      expect(post.likes, ['u2']);
      expect(post.comments, isEmpty);
    });

    test('isLikedBy returns true when userId is in likes', () {
      final post = Post.fromJson({
        'id': 'p1', 'authorId': 'u1', 'authorUsername': 'alice',
        'title': 'T', 'content': 'C', 'tags': [], 'comments': [],
        'likes': ['user-abc'],
        'createdAt': '2024-01-01T00:00:00.000Z',
      });
      expect(post.isLikedBy('user-abc'), isTrue);
      expect(post.isLikedBy('user-xyz'), isFalse);
    });

    test('fromJson handles missing fields gracefully', () {
      final post = Post.fromJson({
        'id': '', 'authorId': '', 'authorUsername': 'x',
        'title': '', 'content': '', 'createdAt': '',
      });
      expect(post.tags, isEmpty);
      expect(post.likes, isEmpty);
      expect(post.comments, isEmpty);
    });
  });
}