import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/auth/data/auth_remote_data_source.dart';
import 'package:mobile/features/auth/domain/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage storage;

  AuthRepository(this.remoteDataSource, this.storage);

  Future<User> login(String email, String password) async {
    print('🔐 AuthRepository: Login attempt for: $email');
    
    final data = await remoteDataSource.login(email, password);
    final token = data['token'];
    final userData = data['user'];
    
    print('📦 Token received: ${token != null}');
    print('👤 User data: $userData');
    print('👤 User role from API: ${userData['role']}');
    
    if (token != null) {
      // Save to secure storage
      await storage.write(key: 'jwt_token', value: token);
      
      // ALSO save to SharedPreferences for compatibility with report feature
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('✅ Token saved to both SecureStorage and SharedPreferences');
    }
    
    // Save user data for offline access
    await storage.write(key: 'user_data', value: userData.toString());
    
    final user = User.fromJson(userData);
    print('✅ User parsed: ${user.email} (${user.role})');
    print('   Is Admin: ${user.isAdmin}');
    
    return user;
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String? sectionId,
  ) async {
    print('📝 AuthRepository: Register attempt for: $email');
    await remoteDataSource.register(name, email, password, sectionId);
    print('✅ Registration successful');
  }

  Future<void> logout() async {
    print('🔓 AuthRepository: Logging out');
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_data');
    
    // Also clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    print('✅ Logout complete');
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    print('✏️ AuthRepository: Updating profile');
    final resData = await remoteDataSource.updateProfile(data);
    final user = User.fromJson(resData);
    
    // Update stored user data
    await storage.write(key: 'user_data', value: resData.toString());
    
    return user;
  }

  // Check if user has a valid token stored
  Future<bool> hasToken() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final hasToken = token != null && token.isNotEmpty;
      print('🔑 Has token: $hasToken');
      return hasToken;
    } catch (e) {
      print('❌ Error checking token: $e');
      return false;
    }
  }

  // Get current user from server using stored token
  Future<User?> getCurrentUser() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        print('❌ No token found');
        return null;
      }
      
      final userData = await remoteDataSource.getCurrentUser();
      print('👤 Current user from server: ${userData['email']} (${userData['role']})');
      
      final user = User.fromJson(userData);
      
      // Update stored user data
      await storage.write(key: 'user_data', value: userData.toString());
      
      // Also update SharedPreferences token to ensure sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      return user;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Get token from secure storage
  Future<String?> getToken() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      print('🔑 Getting token: ${token != null ? 'Found' : 'Not found'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Clear all authentication data (for testing/debugging)
  Future<void> clearAllAuthData() async {
    print('🗑️ Clearing all auth data...');
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_data');
    await storage.deleteAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    print('✅ All auth data cleared');
  }
}
