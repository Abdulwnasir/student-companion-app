import 'package:dio/dio.dart';
import 'package:mobile/features/assignments/domain/assignment_model.dart';

class AssignmentRepository {
  final Dio _dio;

  AssignmentRepository(this._dio);

  Future<List<Assignment>> getAssignments() async {
    final response = await _dio.get('/assignments');
    return (response.data as List).map((e) => Assignment.fromJson(e)).toList();
  }
  Future<void> createAssignment(Map<String, dynamic> data) async {
    await _dio.post('/assignments', data: data);
  }

  Future<void> updateAssignment(String id, Map<String, dynamic> data) async {
    await _dio.patch('/assignments/$id', data: data);
  }

  Future<void> deleteAssignment(String id) async {
    await _dio.delete('/assignments/$id');
  }
}
