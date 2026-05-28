import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_exam_task2/models/post.dart';

void main() {
  group('Comment model', () {
    test('fromJson parses correctly', () {
      final comment = Comment.fromJson({
        'id': 'c1',
        'authorId': 'u1',
        'authorUsername': 'bob',
        'content': 'Great post!',
      });
      expect(comment.id, 'c1');
      expect(comment.content, 'Great post!');
      expect(comment.authorUsername, 'bob');
    });

    test('fromJson handles missing fields', () {
      final comment = Comment.fromJson({});
      expect(comment.id, '');
      expect(comment.content, '');
      expect(comment.authorUsername, '');
    });
  });

  group('Post likes logic', () {
    Post makePost(List<String> likes) => Post.fromJson({
      'id': 'p1', 'authorId': 'u1', 'authorUsername': 'alice',
      'title': 'T', 'content': 'C', 'tags': [], 'comments': [],
      'likes': likes,
      'createdAt': '2024-01-01T00:00:00.000Z',
    });

    test('isLikedBy returns false on empty likes', () {
      expect(makePost([]).isLikedBy('anyone'), isFalse);
    });

    test('isLikedBy returns true for matching userId', () {
      expect(makePost(['u1', 'u2']).isLikedBy('u2'), isTrue);
    });

    test('multiple likes tracked correctly', () {
      final post = makePost(['a', 'b', 'c']);
      expect(post.likes.length, 3);
    });
  });
}