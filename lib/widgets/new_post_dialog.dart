import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/post.dart';
import '../services/post_api_service.dart';

class NewPostDialog extends StatefulWidget {
  const NewPostDialog({super.key, required this.api});
  final PostApiService api;
  @override
  State<NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<NewPostDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;
  String? _error;
  Future<void> _submit() async {
    if (_sending || !_form.currentState!.validate()) return;
    if (!mounted) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response =
          await widget.api.createPost(_title.text.trim(), _body.text.trim());
      if (response.statusCode == 201) {
        final post =
            Post.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
        if (!mounted) return;
        Navigator.pop(context, post);
      } else {
        throw Exception(
            'Could not create post (status ${response.statusCode}).');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Post failed. Check your connection and try again.\n$error';
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_sending,
        child: AlertDialog(
          title: const Text('New Post'),
          content: SingleChildScrollView(
              child: Form(
                  key: _form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Share a thought with the demo API.'),
                    const SizedBox(height: AppSpacing.large),
                    TextFormField(
                        controller: _title,
                        enabled: !_sending,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Title is required'
                                : null),
                    const SizedBox(height: AppSpacing.large),
                    TextFormField(
                        controller: _body,
                        enabled: !_sending,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: 'Body'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Body is required'
                                : null),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.large),
                          child: Text(_error!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                  ]))),
          actions: [
            TextButton(
                onPressed: _sending ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit')),
          ],
        ),
      );
}
