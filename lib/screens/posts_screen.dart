import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../constants/app_theme.dart';
import '../models/post.dart';
import '../services/post_api_service.dart';
import '../widgets/reader_widgets.dart';
import '../widgets/new_post_dialog.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key, this.api});
  final PostApiService? api;
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late final PostApiService _api;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final List<Post> _createdPosts = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? PostApiService();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _api.fetchPosts();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final posts = data
            .map((e) => Post.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (!mounted) return;
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load posts (status ${response.statusCode}).');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not load posts. Check your internet connection.\n$error';
        _isLoading = false;
      });
    }
  }

  Future<void> _newPost() async {
    final post = await showDialog<Post>(
        context: context,
        barrierDismissible: false,
        builder: (_) => NewPostDialog(api: _api));
    if (!mounted || post == null) return;
    setState(() => _createdPosts.insert(0, post));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    showReaderMessage(context, 'Post created successfully (id: ${post.id})');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.api == null) _api.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.large, AppSpacing.small, AppSpacing.large, 96),
        itemCount: 1 +
            _createdPosts.length +
            1 +
            (_isLoading || _errorMessage != null ? 0 : _posts.length),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReaderIntro(
                      eyebrow: 'YOUR DAILY READING SPACE',
                      title: 'Discover. Read. Keep.',
                      subtitle: 'Good reads, collected in one place.',
                      icon: Icons.auto_stories_outlined),
                  if (_createdPosts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.section),
                    Text('Created this session',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Text(
                        'These posts are shown until you restart the app. '
                        'JSONPlaceholder does not save them on the server.'),
                  ],
                ],
              ),
            );
          }
          if (index <= _createdPosts.length) {
            final post = _createdPosts[index - 1];
            // The demo API reuses ID 101. Keep responses separate from
            // server posts and Hive favorites, which use the server ID as key.
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CREATED / RESPONSE #${post.id}',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.small),
                    Text(post.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.small),
                    Text(post.body),
                  ],
                ),
              ),
            );
          }
          final feedIndex = index - _createdPosts.length - 1;
          if (feedIndex == 0) {
            if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.section),
                child: Column(children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.large),
                  Text('Loading posts...'),
                ]),
              );
            }
            if (_errorMessage != null) {
              return StatusView(
                icon: Icons.cloud_off_outlined,
                title: 'Unable to load posts',
                message: _errorMessage!,
                action: ElevatedButton.icon(
                  onPressed: _fetchPosts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              );
            }
            if (_posts.isEmpty) {
              return StatusView(
                icon: Icons.menu_book_outlined,
                title: 'No posts yet',
                message: 'Refresh to check for something new.',
                action: TextButton(
                    onPressed: _fetchPosts, child: const Text('Refresh')),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
              child: Text('Explore / ${_posts.length} posts',
                  style: Theme.of(context).textTheme.titleLarge),
            );
          }
          final post = _posts[feedIndex - 1];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.large),
              leading: PostNumber(id: post.id),
              title: Text(post.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(post.body.replaceAll('\n', ' '),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.details,
                  arguments: post.toMap()),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Post Reader'), actions: [
          IconButton(
              tooltip: 'Favorites',
              icon: const Icon(Icons.favorite_border),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.favorites)),
        ]),
        body: SafeArea(child: ReaderWidth(child: _buildBody())),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _newPost,
            icon: const Icon(Icons.add),
            label: const Text('New Post')),
      );
}
