import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSource(this._dio, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🚀 Login request for: $email');
      
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      
      print('✅ Login response status: ${response.statusCode}');
      print('📦 Response contains token: ${response.data['token'] != null}');
      print('📦 Response contains user: ${response.data['user'] != null}');
      
      if (response.data['user'] != null) {
        print('👤 User role from API: ${response.data['user']['role']}');
        print('👤 User email: ${response.data['user']['email']}');
        print('👤 User name: ${response.data['user']['name']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      print('❌ Login Dio error: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ Login unexpected error: $e');
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String? sectionId,
  ) async {
    try {
      print('📝 Register request for: $email');
      
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'role': 'STUDENT',
      };

      if (sectionId != null) {
        data['sectionId'] = sectionId;
      }

      final response = await _dio.post('/auth/register', data: data);
      print('✅ Register response status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Register error: ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      print('✏️ Update profile request');
      
      final token = await _storage.read(key: 'jwt_token');
      final response = await _dio.patch(
        '/users/profile',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('✅ Update profile response status: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Update profile error: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('👤 Get current user request');
      
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        print('❌ No token found');
        throw Exception('No authentication token');
      }
      
      final response = await _dio.get(
        '/users/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      print('✅ Get current user response status: ${response.statusCode}');
      if (response.data != null) {
        print('👤 User role: ${response.data['role']}');
      }
      
      return response.data;
    } on DioException catch (e) {
      print('❌ Get current user error: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
