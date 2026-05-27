class Comment {
  final String id;
  final String authorId;
  final String authorUsername;
  final String content;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class Post {
  final String id;
  final String authorId;
  final String authorUsername;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.title,
    required this.content,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromJson(c))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool isLikedBy(String userId) => likes.contains(userId);
}
