import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OrganizationRepository {
  final Dio _dio;

  OrganizationRepository(this._dio);

  Future<List<dynamic>> getDepartments() async {
    try {
      final response = await _dio.get('/organization/departments');
      return response.data;
    } catch (e) {
      debugPrint('Error getting departments: $e');
      return [];
    }
  }

  Future<List<dynamic>> getBatches(String departmentId) async {
    try {
      final response = await _dio.get('/organization/batches/$departmentId');
      return response.data;
    } catch (e) {
      debugPrint('Error getting batches: $e');
      return [];
    }
  }

  Future<List<dynamic>> getSections(String batchId) async {
    try {
      final response = await _dio.get('/organization/sections/$batchId');
      return response.data;
    } catch (e) {
      debugPrint('Error getting sections: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllBatches() async {
    try {
      final response = await _dio.get('/organization/all-batches');
      return response.data;
    } catch (e) {
      debugPrint('Error getting all batches: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllSections() async {
    try {
      final response = await _dio.get('/organization/all-sections');
      return response.data;
    } catch (e) {
      debugPrint('Error getting all sections: $e');
      return [];
    }
  }
}
