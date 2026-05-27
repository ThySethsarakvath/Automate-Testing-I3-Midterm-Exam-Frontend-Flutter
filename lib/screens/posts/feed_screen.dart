import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // ignore: use_build_context_synchronously
    Future.microtask(() => context.read<PostProvider>().loadAllPosts());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final posts = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('createPostFab'),
        onPressed: () => context.push('/create'),
        child: const Icon(Icons.add),
      ),
      body: posts.isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(posts.error!, key: const Key('feedError')),
                  TextButton(
                    onPressed: () =>
                        context.read<PostProvider>().loadAllPosts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : posts.posts.isEmpty
          ? const Center(
              child: Text(
                'No posts yet.\nTap + to create the first one!',
                key: Key('emptyFeed'),
                textAlign: TextAlign.center,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => context.read<PostProvider>().loadAllPosts(),
              child: ListView.builder(
                key: const Key('postsList'),
                padding: const EdgeInsets.all(8),
                itemCount: posts.posts.length,
                itemBuilder: (ctx, i) => _PostCard(
                  post: posts.posts[i],
                  currentUserId: auth.user?.id ?? '',
                ),
              ),
            ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;

  const _PostCard({required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isOwner = post.authorId == currentUserId;
    final isLiked = post.isLikedBy(currentUserId);

    return Card(
      key: Key('postCard_${post.id}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => context.push('/posts/${post.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    child: Text(post.authorUsername[0].toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorUsername,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(post.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner) ...[
                    IconButton(
                      key: Key('editPost_${post.id}'),
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => context.push('/edit/${post.id}'),
                    ),
                    IconButton(
                      key: Key('deletePost_${post.id}'),
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              // Tags
              if (post.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: post.tags
                      .map(
                        (t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              // Footer: likes & comments
              Row(
                children: [
                  IconButton(
                    key: Key('likeButton_${post.id}'),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () => context.read<PostProvider>().toggleLike(
                      post.id,
                      currentUserId,
                    ),
                  ),
                  Text('${post.likes.length}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.comment_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text('${post.comments.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            key: const Key('cancelDelete'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirmDelete'),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<PostProvider>().deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
