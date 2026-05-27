import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/post.dart';

class PostService {
  final Future<String?> Function() getToken;

  PostService({required this.getToken});

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Get all posts ─────────────────────────────────────────────────────
  Future<List<Post>> getAllPosts() async {
    final response = await http.get(Uri.parse(ApiConfig.posts));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Post.fromJson(p)).toList();
    }
    throw Exception('Failed to load posts');
  }

  // ── Get feed ──────────────────────────────────────────────────────────
  Future<List<Post>> getFeed() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.feed),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => Post.fromJson(p)).toList();
    }
    throw Exception('Failed to load feed');
  }

  // ── Get single post ───────────────────────────────────────────────────
  Future<Post> getPostById(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.posts}/$id'));
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Post not found');
  }

  // ── Create post ───────────────────────────────────────────────────────
  Future<Post> createPost({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.posts),
      headers: headers,
      body: jsonEncode({'title': title, 'content': content, 'tags': tags}),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    }
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Failed to create post');
  }

  // ── Update post ───────────────────────────────────────────────────────
  Future<Post> updatePost({
    required String id,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    if (tags != null) body['tags'] = tags;

    final response = await http.patch(
      Uri.parse('${ApiConfig.posts}/$id'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    final data = jsonDecode(response.body);
    throw Exception(data['message'] ?? 'Failed to update post');
  }

  // ── Delete post ───────────────────────────────────────────────────────
  Future<void> deletePost(String id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConfig.posts}/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────
  Future<Post> likePost(String id) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.posts}/$id/like'),
      headers: headers,
    );
    if (response.statusCode == 200)
      return Post.fromJson(jsonDecode(response.body));
    throw Exception('Failed to like post');
  }

  Future<Post> unlikePost(String id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConfig.posts}/$id/like'),
      headers: headers,
    );
    if (response.statusCode == 200)
      return Post.fromJson(jsonDecode(response.body));
    throw Exception('Failed to unlike post');
  }

  // ── Comment ───────────────────────────────────────────────────────────
  Future<Comment> addComment(String postId, String content) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.posts}/$postId/comments'),
      headers: headers,
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 201) {
      return Comment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add comment');
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConfig.posts}/$postId/comments/$commentId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
