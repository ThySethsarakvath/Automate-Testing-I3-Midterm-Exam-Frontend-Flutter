import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService postService;

  PostProvider({required this.postService});

  List<Post> _posts   = [];
  bool       _loading = false;
  String?    _error;

  List<Post> get posts     => _posts;
  bool       get isLoading => _loading;
  String?    get error     => _error;

  Future<void> loadAllPosts() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _posts = await postService.getAllPosts();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _loading = false; notifyListeners();
  }

  Future<bool> createPost({
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final post = await postService.createPost(
        title: title, content: content, tags: tags,
      );
      _posts.insert(0, post);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePost({
    required String id,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    try {
      final updated = await postService.updatePost(
        id: id, title: title, content: content, tags: tags,
      );
      final idx = _posts.indexWhere((p) => p.id == id);
      if (idx != -1) _posts[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String id) async {
    try {
      await postService.deletePost(id);
      _posts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    try {
      Post updated;
      if (post.isLikedBy(userId)) {
        updated = await postService.unlikePost(postId);
      } else {
        updated = await postService.likePost(postId);
      }
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) _posts[idx] = updated;
      notifyListeners();
    } catch (_) {}
  }

  void clearError() { _error = null; notifyListeners(); }
}