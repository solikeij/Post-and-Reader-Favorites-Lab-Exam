import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_routes.dart';
import '../constants/app_theme.dart';
import '../models/post.dart';
import '../services/favorites_service.dart';
import '../widgets/reader_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favorites = FavoritesService();
  final Set<int> _removing = {};

  Future<void> _editNote(Map<String, dynamic> item) async {
    final controller =
        TextEditingController(text: item['note'] as String? ?? '');
    final note = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Edit personal note'),
              content: SingleChildScrollView(
                  child: TextField(
                      controller: controller,
                      maxLength: 100,
                      maxLines: 3,
                      autofocus: true,
                      decoration: const InputDecoration(
                          labelText: 'Your note',
                          hintText: 'Why is this worth keeping?'))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, controller.text.trim()),
                    child: const Text('Save')),
              ],
            ));
    // The dialog route disposes after its reverse animation.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (note == null || !mounted) return;
    try {
      await _favorites.updateNote(item['id'] as int, note);
      if (!mounted) return;
      showReaderMessage(context, 'Note updated');
    } catch (error) {
      if (!mounted) return;
      showReaderMessage(context, 'Could not update note: $error', error: true);
    }
  }

  Future<void> _remove(Map<String, dynamic> item,
      {bool confirm = false}) async {
    final id = item['id'] as int;
    if (!_removing.add(id)) return;
    try {
      if (confirm) {
        final approved = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: const Text('Remove favorite?'),
                  content: const Text(
                      'This also removes your personal note. You can undo immediately afterwards.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Remove')),
                  ],
                ));
        if (approved != true || !mounted) return;
      }
      await _favorites.remove(id);
      if (!mounted) return;
      showReaderMessage(context, 'Favorite removed',
          action: SnackBarAction(
              label: 'Undo',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () => _restore(item)));
    } catch (error) {
      if (!mounted) return;
      showReaderMessage(context, 'Could not remove favorite: $error',
          error: true);
    } finally {
      _removing.remove(id);
    }
  }

  Future<void> _restore(Map<String, dynamic> item) async {
    try {
      await _favorites.restore(item);
      if (!mounted) return;
      showReaderMessage(context, 'Favorite restored');
    } catch (error) {
      if (!mounted) return;
      showReaderMessage(context, 'Could not restore favorite: $error',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('My Favorites'),
            leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context))),
        body: SafeArea(
            child: ReaderWidth(
                child: ValueListenableBuilder(
          valueListenable: _favorites.box.listenable(),
          builder: (context, box, _) {
            final items = _favorites.all();
            if (items.isEmpty) {
              return StatusView(
                  icon: Icons.favorite_border,
                  title: 'No favorites yet',
                  message:
                      'Save a post that speaks to you. Your reading collection will live here.',
                  action: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to reading')));
            }
            final theme = Theme.of(context);
            return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.large),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.section),
                        child: ReaderIntro(
                          eyebrow: 'YOUR PERSONAL COLLECTION',
                          title: 'Worth keeping.',
                          subtitle:
                              '${items.length} saved posts. Yours to revisit, even offline.',
                          icon: Icons.favorite_border,
                        ));
                  }
                  final item = items[index - 1];
                  final post = Post.fromMap(item);
                  final note = item['note'] as String? ?? '';
                  return Dismissible(
                    key: ValueKey(post.id),
                    direction: DismissDirection.endToStart,
                    // Delete before animation completion; a failed write leaves the item visible.
                    confirmDismiss: (_) async {
                      await _remove(item);
                      return false;
                    },
                    background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(AppSpacing.section),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radius)),
                        child: Icon(Icons.delete_outline,
                            color: theme.colorScheme.onError)),
                    child: Card(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          ListTile(
                              contentPadding:
                                  const EdgeInsets.all(AppSpacing.large),
                              leading: PostNumber(id: post.id),
                              title: Text(post.title,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text(post.body.replaceAll('\n', ' '),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.details,
                                  arguments: post.toMap())),
                          if (note.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.large),
                                child: Text(note,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: theme
                                            .colorScheme.onSurfaceVariant))),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    tooltip: 'Edit note',
                                    icon: const Icon(Icons.edit_note),
                                    onPressed: () => _editNote(item)),
                                IconButton(
                                    tooltip: 'Delete favorite',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        _remove(item, confirm: true)),
                                const SizedBox(width: AppSpacing.small),
                              ]),
                        ])),
                  );
                });
          },
        ))),
      );
}
