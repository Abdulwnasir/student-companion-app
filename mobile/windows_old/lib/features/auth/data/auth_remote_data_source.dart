import 'package:dio/dio.dart';
// Assuming this exists or should exist

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String sectionId,
  ) async {
    await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'STUDENT',
        'sectionId': sectionId,
      },
    );
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/profile', data: data);
    return response.data;
  }
}
