import 'dart:io';
import 'package:dio/dio.dart';
import '../domain/study_material_model.dart';

class StudyMaterialRepository {
  final Dio _dio;

  StudyMaterialRepository(this._dio);

  Future<List<StudyMaterial>> getMaterials({String? course, String? query}) async {
    final response = await _dio.get('/materials', queryParameters: {
      if (course != null) 'course': course,
      if (query != null) 'q': query,
    });
    return (response.data as List).map((e) => StudyMaterial.fromJson(e)).toList();
  }

  Future<void> uploadMaterial(String title, String courseName, File file) async {
    final formData = FormData.fromMap({
      'title': title,
      'courseName': courseName,
      'file': await MultipartFile.fromFile(file.path),
    });

    await _dio.post('/materials/upload', data: formData);
  }

  Future<void> deleteMaterial(String id) async {
    await _dio.delete('/materials/$id');
  }
}
