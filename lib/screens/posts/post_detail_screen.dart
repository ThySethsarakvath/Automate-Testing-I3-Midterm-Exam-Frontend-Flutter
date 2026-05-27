import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final provider = context.watch<PostProvider>();
    final post   = provider.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => provider.posts.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('by ${post.authorUsername}',
                style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Text(post.content),
            const SizedBox(height: 16),
            // Like section
            Row(
              children: [
                IconButton(
                  key: const Key('detailLikeButton'),
                  icon: Icon(
                    post.isLikedBy(auth.user?.id ?? '')
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.isLikedBy(auth.user?.id ?? '')
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () => context
                      .read<PostProvider>()
                      .toggleLike(post.id, auth.user?.id ?? ''),
                ),
                Text('${post.likes.length} likes'),
              ],
            ),
            const Divider(),
            // Comments section
            Text('Comments (${post.comments.length})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...post.comments.map((c) => ListTile(
              key: Key('comment_${c.id}'),
              leading: CircleAvatar(
                  child: Text(c.authorUsername[0].toUpperCase())),
              title:    Text(c.content),
              subtitle: Text(c.authorUsername),
              trailing: c.authorId == auth.user?.id
                  ? IconButton(
                      key: Key('deleteComment_${c.id}'),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final svc = context
                            .read<PostProvider>()
                            .postService;
                        await svc.deleteComment(post.id, c.id);
                        if (context.mounted) {
                          await context.read<PostProvider>().loadAllPosts();
                        }
                      },
                    )
                  : null,
            )),
            const SizedBox(height: 16),
            // Add comment
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('commentField'),
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: const Key('submitComment'),
                  onPressed: () async {
                    if (_commentCtrl.text.trim().isEmpty) return;
                    final svc = context.read<PostProvider>().postService;
                    await svc.addComment(post.id, _commentCtrl.text.trim());
                    _commentCtrl.clear();
                    if (context.mounted) {
                      await context.read<PostProvider>().loadAllPosts();
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}