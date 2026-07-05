import 'dart:io';
import 'package:dio/dio.dart';
import '../domain/discussion_model.dart';
import '../domain/group_resource_model.dart';

class DiscussionRepository {
  final Dio _dio;

  DiscussionRepository(this._dio);

  Future<List<DiscussionGroup>> getGroups() async {
    final response = await _dio.get('/discussions/groups');
    print('API Response: ${response.data}');
    print('Response type: ${response.data.runtimeType}');
    if (response.data is List) {
      print('List length: ${(response.data as List).length}');
    }
    return (response.data as List).map((e) => DiscussionGroup.fromJson(e)).toList();
  }

  Future<void> createGroup(String name, String description) async {
    await _dio.post('/discussions/groups', data: {
      'name': name,
      'description': description,
    });
  }

  Future<List<DiscussionMessage>> getGroupMessages(String groupId) async {
    final response = await _dio.get('/discussions/groups/$groupId/messages');
    return (response.data as List).map((e) => DiscussionMessage.fromJson(e)).toList();
  }

  Future<void> postMessage(String groupId, String content, File? file) async {
    final formData = FormData.fromMap({
      'groupId': groupId,
      'content': content,
      if (file != null)
        'file': await MultipartFile.fromFile(file.path),
    });

    await _dio.post('/discussions/messages', data: formData);
  }

  Future<void> postComment(String messageId, String content) async {
    await _dio.post('/discussions/comments', data: {
      'messageId': messageId,
      'content': content,
    });
  }

  Future<List<DiscussionMessage>> searchDiscussions(String query) async {
    final response = await _dio.get('/discussions/search', queryParameters: {'q': query});
    return (response.data as List).map((e) => DiscussionMessage.fromJson(e)).toList();
  }

  Future<List<GroupResource>> getGroupResources(String groupId) async {
    final response = await _dio.get('/discussions/groups/$groupId/resources');
    return (response.data as List).map((e) => GroupResource.fromJson(e)).toList();
  }

  Future<void> addResource(String groupId, String title, String link) async {
    await _dio.post('/discussions/groups/$groupId/resources', data: {
      'title': title,
      'link': link,
    });
  }

  Future<void> deleteResource(String resourceId) async {
    await _dio.delete('/discussions/resources/$resourceId');
  }
}
