import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client injection keeps network failure and status-code tests deterministic.
class PostApiService {
  PostApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static final endpoint =
      Uri.parse('https://jsonplaceholder.typicode.com/posts');
  static const requestTimeout = Duration(seconds: 15);

  Future<http.Response> fetchPosts() async {
    final response = await _client.get(endpoint).timeout(requestTimeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts (status ${response.statusCode}).');
    }
    return response;
  }

  Future<http.Response> createPost(String title, String body) => _client
      .post(
        endpoint,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
      )
      .timeout(requestTimeout);

  void dispose() => _client.close();
}
