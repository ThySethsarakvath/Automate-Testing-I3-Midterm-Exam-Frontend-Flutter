import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  const EditPostScreen({super.key, required this.postId});
  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final posts = context.read<PostProvider>();
      final post = posts.posts.firstWhere(
        (p) => p.id == widget.postId,
        orElse: () => posts.posts.first,
      );
      _titleCtrl.text = post.title;
      _contentCtrl.text = post.content;
      _tagsCtrl.text = post.tags.join(', ');
      _initialized = true;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final ok = await context.read<PostProvider>().updatePost(
      id: widget.postId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      tags: tags,
    );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (posts.error != null)
                Container(
                  key: const Key('editError'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    posts.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                key: const Key('titleField'),
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('contentField'),
                controller: _contentCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Content *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Content is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('tagsField'),
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('updatePostButton'),
                  onPressed: posts.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: posts.isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Update Post',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
