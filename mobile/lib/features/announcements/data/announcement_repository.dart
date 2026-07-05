import 'package:dio/dio.dart';
import '../domain/announcement_model.dart';

class AnnouncementRepository {
  final Dio _dio;

  AnnouncementRepository(this._dio);

  Future<List<Announcement>> getActiveAnnouncements() async {
    try {
      print('📢 Fetching active announcements...');
      print('📍 URL: ${_dio.options.baseUrl}/announcements/active');
      
      final response = await _dio.get('/announcements/active');
      
      print('✅ Response status: ${response.statusCode}');
      
      if (response.data is List) {
        print('📊 Found ${(response.data as List).length} announcements');
        
        final announcements = <Announcement>[];
        for (var i = 0; i < (response.data as List).length; i++) {
          try {
            final announcement = Announcement.fromJson(response.data[i]);
            announcements.add(announcement);
            print('✓ Parsed announcement ${i + 1}: ${announcement.title}');
          } catch (e) {
            print('❌ Error parsing announcement ${i + 1}: $e');
          }
        }
        
        return announcements;
      } else {
        print('⚠️ Unexpected response structure: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ Error fetching announcements:');
      print('   Message: ${e.message}');
      if (e.response?.statusCode == 401) {
        print('⚠️ Authentication required. Please log in.');
      } else if (e.response?.statusCode == 404) {
        print('⚠️ Endpoint not found. Expected: /api/announcements/active');
      }
      return [];
    } catch (e) {
      print('❌ Unexpected error: $e');
      return [];
    }
  }

  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    required String type,
    required String source,
    required DateTime deadline,
  }) async {
    try {
      print('📝 Creating announcement: $title');
      
      final response = await _dio.post('/announcements', data: {
        'title': title,
        'content': content,
        'type': type,
        'source': source,
        'deadline': deadline.toIso8601String(),
      });
      
      print('✅ Announcement created successfully');
      return Announcement.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error creating announcement: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      print('🗑️ Deleting announcement: $id');
      await _dio.delete('/announcements/$id');
      print('✅ Announcement deleted successfully');
    } catch (e) {
      print('❌ Error deleting announcement: $e');
      rethrow;
    }
  }
}
