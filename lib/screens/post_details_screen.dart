import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_routes.dart';
import '../constants/app_theme.dart';
import '../models/post.dart';
import '../services/favorites_service.dart';
import '../widgets/reader_widgets.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});
  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _favorites = FavoritesService();
  bool _saving = false;
  Future<void> _save(Post post) async {
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final existed = _favorites.isFavorite(post.id);
      await _favorites.save(post);
      if (!mounted) return;
      showReaderMessage(
          context, existed ? 'Already in favorites' : 'Saved to favorites');
    } catch (error) {
      if (!mounted) return;
      showReaderMessage(context, 'Could not save favorite: $error',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final post = Post.fromMap(arguments);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text('Post Details'),
          leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
                tooltip: 'Favorites',
                icon: const Icon(Icons.favorite_border),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.favorites))
          ]),
      body: SafeArea(
          child: ReaderWidth(
              child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.section),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TAKE A MOMENT TO READ',
                            style: theme.textTheme.labelSmall),
                        const SizedBox(height: AppSpacing.large),
                        Chip(
                            avatar: const Icon(Icons.article_outlined),
                            label: Text('POST ${post.id}')),
                        const SizedBox(height: AppSpacing.large),
                        Text(post.title, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.small),
                        const Divider(),
                        Text(post.body, style: theme.textTheme.bodyLarge),
                      ]))),
          const SizedBox(height: AppSpacing.small),
          ValueListenableBuilder(
              valueListenable: _favorites.box.listenable(),
              builder: (context, box, _) {
                final saved = _favorites.isFavorite(post.id);
                return ElevatedButton.icon(
                    onPressed: _saving ? null : () => _save(post),
                    icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
                    label: Text(_saving
                        ? 'Saving…'
                        : saved
                            ? 'Saved ✓'
                            : 'Save to Favorites'));
              }),
          const SizedBox(height: AppSpacing.small),
          Text('Keep this post and add a personal note in My Favorites.',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.favorites),
              child: const Text('Open My Favorites')),
        ]),
      ))),
    );
  }
}
