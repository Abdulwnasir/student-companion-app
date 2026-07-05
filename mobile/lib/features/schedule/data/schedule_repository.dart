import 'package:dio/dio.dart';
import 'package:mobile/features/schedule/domain/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository(this._dio);

  Future<List<Schedule>> getSchedule() async {
    print('Fetching schedule from /schedules/my');
    final response = await _dio.get('/schedules/my');
    print('Schedule response: ${response.data}');
    print('Schedule count: ${(response.data as List).length}');
    return (response.data as List).map((e) => Schedule.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getWeeklyTimetable() async {
    final response = await _dio.get('/schedules/timetable');
    return response.data as Map<String, dynamic>;
  }

  Future<void> addSchedule(Map<String, dynamic> data) async {
    await _dio.post('/schedules', data: data);
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    await _dio.patch('/schedules/$id', data: data);
  }

  Future<void> deleteSchedule(String id) async {
    await _dio.delete('/schedules/$id');
  }
}
