import 'package:dio/dio.dart';
import '../domain/study_session_model.dart';

class AIRepository {
  final Dio _dio;

  AIRepository(this._dio);

  Future<String> askAI(String question) async {
    final response = await _dio.post('/ai/ask', data: {'question': question});
    return response.data['answer'];
  }
  Future<List<dynamic>> getStudySuggestions() async {
    final response = await _dio.get('/ai/suggestions');
    return response.data;
  }

  Future<Map<String, dynamic>> getWorkloadAnalysis() async {
    final response = await _dio.get('/ai/workload');
    return response.data;
  }

  Future<List<dynamic>> getPrioritizedTasks() async {
    final response = await _dio.get('/ai/prioritize');
    return response.data;
  }

  Future<List<dynamic>> getSmartReminders() async {
    final response = await _dio.get('/ai/reminders');
    return response.data;
  }

  Future<List<StudySession>> getMySessions() async {
    final response = await _dio.get('/study-sessions/my');
    return (response.data as List).map((s) => StudySession.fromJson(s)).toList();
  }

  Future<StudySession> addStudySession(Map<String, dynamic> data) async {
    final response = await _dio.post('/study-sessions', data: data);
    return StudySession.fromJson(response.data);
  }

  Future<void> deleteStudySession(String id) async {
    await _dio.delete('/study-sessions/$id');
  }
}
