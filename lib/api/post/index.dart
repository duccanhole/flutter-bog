import 'dart:convert';

import 'package:app/api/index.dart';
import 'package:app/interface/Post.interface.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuerySearch {
  String skip;
  String limit;
  String sortBy;
  QuerySearch({this.limit = '10', this.skip = '0', this.sortBy = ""});
}

class PostApi {
  Future<List<IPost>> getList(QuerySearch q) async {
    final query = {"skip": q.skip, "limit": q.limit, "sortBy": q.sortBy};
    final uri = Uri.http(rootUrl, "post", query);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List resData = jsonDecode(response.body)['results'];
      return resData.map((e) => IPost.fromJson(e)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load from server');
    }
  }

  Future<http.Response?> createPost(
      String title, String subtitle, String tags, String link) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    String? token = prefs.getString("token");
    if (userId!.isNotEmpty && token!.isNotEmpty) {
      try {
        return http.post(Uri.http(rootUrl, "post/create"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'token': token
            },
            body: json.encode({
              'title': title,
              'subtitle': subtitle,
              'url': link,
              'tags': tags,
              'userId': userId
            }));
      } catch (e) {
        throw Exception(e);
      }
    }
    return null;
  }
}
