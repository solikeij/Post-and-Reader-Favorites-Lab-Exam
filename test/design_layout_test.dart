import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:post_reader_favorites/app.dart';
import 'package:post_reader_favorites/models/post.dart';
import 'package:post_reader_favorites/services/favorites_service.dart';
import 'package:post_reader_favorites/services/post_api_service.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('dark reading layouts fit $size with enlarged text',
        (tester) async {
      final directory = (await tester.runAsync(() async {
        final result = await Directory.systemTemp.createTemp('reader_layout');
        Hive.init(result.path);
        await Hive.openBox(kFavoritesBox);
        return result;
      }))!;
      const post = Post(
          id: 1,
          title: 'A little space for a good read',
          body:
              'Collect the ideas that stay with you. Save a favorite and leave a personal note to return to later.');
      await tester.runAsync(() => FavoritesService().save(post));
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() async {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      final fontDirectory = Platform.environment['PREVIEW_FONT_DIR'];
      if (fontDirectory != null) {
        await tester.runAsync(() async {
          for (final entry in {
            'Roboto': 'roboto-regular.ttf',
            'MaterialIcons': 'materialicons-regular.otf',
          }.entries) {
            final loader = FontLoader(entry.key);
            loader.addFont(File('$fontDirectory/${entry.value}')
                .readAsBytes()
                .then((bytes) => ByteData.sublistView(bytes)));
            await loader.load();
          }
        });
      }
      final api = PostApiService(
          client: MockClient((_) async => http.Response(
              '[{"id":1,"title":"A little space for a good read","body":"Collect the ideas that stay with you. Save a favorite and leave a personal note to return to later."},'
              '{"id":2,"title":"Make room for curiosity","body":"A fresh perspective can begin with a single paragraph."},'
              '{"id":3,"title":"Ideas worth coming back to","body":"Build a collection that feels like you."}]',
              200)));
      addTearDown(api.dispose);
      final previewKey = GlobalKey();
      await tester.pumpWidget(
          RepaintBoundary(key: previewKey, child: PostReaderApp(api: api)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (Platform.environment['CAPTURE_PREVIEW'] == '1' && size.width == 390) {
        final boundary = previewKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final snapshot = await boundary.toImage(pixelRatio: 2);
          final data =
              await snapshot.toByteData(format: ui.ImageByteFormat.png);
          await Directory('design_preview').create();
          await File('design_preview/posts.png')
              .writeAsBytes(data!.buffer.asUint8List());
          snapshot.dispose();
        });
      }
      await tester.scrollUntilVisible(find.text(post.title), 150);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(post.title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(post.title));
      await tester.pumpAndSettle();
      expect(find.text('Post Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('My Favorites'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byTooltip('Edit note'), 150);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Edit note'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit note'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New Post'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  }
}
