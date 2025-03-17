import 'package:kexie_app/internet/network.dart';
import 'package:kexie_app/models/forum_posts/forum_posts.dart';

class ForumRepository {
  final dio = AppNetwork.get().appDio;

  Future<ForumPosts> getPosts({
    int page = 1,
    int pageSize = 30,
    String sortBy = 'created_at',
    String order = 'desc',
    int? userId,
    String? categoryId,
    int? parentId,
  }) async {
    final queryParameters = {
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      'order': order,
      if (userId != null) 'user_id': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (parentId != null) "parent_id": parentId
    };

    final response = await dio.get(
      '/forum/get_posts',
      queryParameters: queryParameters,
    );
    final postsResp = ForumPosts.fromJson(response.data);
    print(postsResp.data.length);
    return postsResp
      ..data = postsResp.data
          .map((e) => e
        ..images =
        e.images.map((e) => "http://jzhangluo.com:9000$e").toList())
          .toList();
  }

  Future<int> like(int postId) async {
    final response = await dio.put("/forum/like/$postId");
    return response.data['code'];
  }

  Future<int> unlike(int postId) async {
    final response = await dio.delete("/forum/unlike/$postId");
    return response.data['code'];
  }

  Future<int> view(int postId) async {
    final response = await dio.put("/forum/watch/$postId");
    return response.data['code'];
  }

  Future<int> deletePost(int postId) async {
    final response = await dio.delete("/forum/delete/$postId");
    return response.data['code'];
  }

  ForumRepository._create();

  static ForumRepository? _instance;

  factory ForumRepository.get() => _instance ??= ForumRepository._create();

}