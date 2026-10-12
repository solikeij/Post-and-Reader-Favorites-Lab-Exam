import 'package:flutter/material.dart';
import 'constants/app_routes.dart';
import 'constants/app_theme.dart';
import 'screens/posts_screen.dart';
import 'screens/post_details_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/post_api_service.dart';

class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key, this.api});
  final PostApiService? api;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Post Reader & Favorites',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.posts,
        routes: {
          AppRoutes.posts: (_) => PostsScreen(api: api),
          AppRoutes.details: (_) => const PostDetailsScreen(),
          AppRoutes.favorites: (_) => const FavoritesScreen(),
        },
      );
}
