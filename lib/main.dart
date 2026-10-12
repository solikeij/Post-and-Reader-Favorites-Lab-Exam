import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'constants/app_theme.dart';
import 'services/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await Hive.openBox(kFavoritesBox);
    runApp(const PostReaderApp());
  } catch (error) {
    // Storage failures must be visible instead of leaving a blank startup screen.
    runApp(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          appBar: AppBar(title: const Text('Post Reader')),
          body: SafeArea(
              child: Center(
                  child: Padding(
            padding: const EdgeInsets.all(AppSpacing.section),
            child: Text(
                'Could not open local favorites. Restart the app to retry.\n$error'),
          ))),
        )));
  }
}
