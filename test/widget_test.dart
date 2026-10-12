import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:post_reader_favorites/app.dart';
import 'package:post_reader_favorites/models/post.dart';
import 'package:post_reader_favorites/services/favorites_service.dart';
import 'package:post_reader_favorites/services/post_api_service.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('post_reader_test');
    Hive.init(directory.path);
    await Hive.openBox(kFavoritesBox);
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('favorites preserve notes, survive reopen, delete and restore',
      () async {
    final service = FavoritesService();
    const post = Post(id: 7, title: 'A good read', body: 'A longer body');
    await service.save(post);
    await service.updateNote(7, 'Remember this');
    await service.save(post);
    expect(service.all(), hasLength(1));
    expect(service.all().single['note'], 'Remember this');
    await Hive.close();
    await Hive.openBox(kFavoritesBox);
    expect(service.all().single['note'], 'Remember this');
    final removed = service.all().single;
    await service.remove(7);
    expect(service.isFavorite(7), isFalse);
    await service.restore(removed);
    expect(service.all().single['note'], 'Remember this');
  });

  test('GET rejects non-200 and POST sends JSON with userId', () async {
    final api = PostApiService(client: MockClient((request) async {
      if (request.method == 'GET') return http.Response('Unavailable', 503);
      expect(request.headers['content-type'], contains('application/json'));
      expect(jsonDecode(request.body),
          {'title': 'Title', 'body': 'Body', 'userId': 1});
      return http.Response('{"id":101,"title":"Title","body":"Body"}', 201);
    }));
    addTearDown(api.dispose);
    await expectLater(api.fetchPosts(),
        throwsA(predicate((e) => e.toString().contains('503'))));
    expect((await api.createPost('Title', 'Body')).statusCode, 201);
  });

  testWidgets('navigation, save, note, confirmed delete and undo',
      (tester) async {
    await tester.runAsync(() async {
      final api = PostApiService(
          client: MockClient((_) async => http.Response(
              '[{"id":7,"title":"A good read","body":"A longer body"}]', 200)));
      addTearDown(api.dispose);
      await tester.pumpWidget(PostReaderApp(api: api));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A good read'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('Post Details'), findsOneWidget);
      await tester.tap(find.text('Save to Favorites'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open My Favorites'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit note'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My own note');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('My own note'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete favorite'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('No favorites yet'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('My own note'), findsOneWidget);
      await tester.drag(find.byKey(const ValueKey(7)), const Offset(-700, 0));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('No favorites yet'), findsOneWidget);
    });
  });

  testWidgets('GET error retries; form validates and displays POST success',
      (tester) async {
    await tester.runAsync(() async {
      var getCount = 0;
      final api = PostApiService(client: MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response(
              '{"id":101,"title":"New title","body":"New body"}', 201);
        }
        if (getCount++ == 0) return http.Response('Unavailable', 503);
        return http.Response('[{"id":1,"title":"First","body":"Body"}]', 200);
      }));
      addTearDown(api.dispose);
      await tester.pumpWidget(PostReaderApp(api: api));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.textContaining('503'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      await tester.tap(find.text('New Post'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Body is required'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'New title');
      await tester.enterText(find.byType(TextFormField).at(1), 'New body');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('Post created successfully (id: 101)'), findsOneWidget);
      expect(find.text('Created this session'), findsOneWidget);
    });
  });

  testWidgets('POST failure stays visible and keeps the entered text',
      (tester) async {
    await tester.runAsync(() async {
      final api = PostApiService(
          client: MockClient((request) async => request.method == 'POST'
              ? http.Response('Unavailable', 500)
              : http.Response('[]', 200)));
      addTearDown(api.dispose);
      await tester.pumpWidget(PostReaderApp(api: api));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New Post'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Draft');
      await tester.enterText(find.byType(TextFormField).at(1), 'Draft body');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.textContaining('500'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
    });
  });

  for (final feedStatus in [200, 503]) {
    testWidgets('created posts remain visible with feed status $feedStatus',
        (tester) async {
      var number = 0;
      final api = PostApiService(client: MockClient((request) async {
        if (request.method == 'POST') {
          number++;
          return http.Response(
              jsonEncode({
                'id': 101,
                'title': 'Created $number',
                'body': 'Body $number',
              }),
              201);
        }
        return http.Response('[]', feedStatus);
      }));
      addTearDown(api.dispose);
      await tester.pumpWidget(PostReaderApp(api: api));
      await tester.pumpAndSettle();
      for (var i = 1; i <= 2; i++) {
        await tester.tap(find.text('New Post'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).at(0), 'Created $i');
        await tester.enterText(find.byType(TextFormField).at(1), 'Body $i');
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();
        expect(find.text('Created $i'), findsOneWidget);
      }
      expect(find.text('Created 1'), findsOneWidget);
      expect(find.text('Created 2'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(find.text('Created 1'), findsOneWidget);
      expect(find.text('Created 2'), findsOneWidget);
    });
  }

  testWidgets('submitting from a scrolled feed reveals the new post',
      (tester) async {
    final api = PostApiService(client: MockClient((request) async {
      if (request.method == 'POST') {
        return http.Response(
            '{"id":101,"title":"Visible new post","body":"New body"}', 201);
      }
      return http.Response(
          jsonEncode(List.generate(
              50,
              (i) => {
                    'id': i + 1,
                    'title': 'Post $i',
                    'body': 'Body $i',
                  })),
          200);
    }));
    addTearDown(api.dispose);
    await tester.pumpWidget(PostReaderApp(api: api));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Post'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).at(0), 'Visible new post');
    await tester.enterText(find.byType(TextFormField).at(1), 'New body');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Visible new post').hitTestable(), findsOneWidget);
  });
}
