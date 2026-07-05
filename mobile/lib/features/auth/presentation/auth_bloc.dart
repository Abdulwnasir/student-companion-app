import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) 
      : super(const AuthState(status: AuthStatus.unauthenticated)) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateUserSettings>(_onUpdateUserSettings);
    on<ResetAuthState>(_onResetAuthState);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event, 
    Emitter<AuthState> emit
  ) async {
    print('🔐 Checking auth status...');
    
    // Check if token exists in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null && token.isNotEmpty) {
      print('✅ Token found, user is authenticated');
      // You could also validate token with backend here
      emit(AuthState(
        status: AuthStatus.authenticated,
        token: token,
      ));
    } else {
      print('❌ No token found, showing login page');
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event, 
    Emitter<AuthState> emit
  ) async {
    print('🔐 Login submitted for: ${event.email}');
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final result = await authRepository.login(event.email, event.password);
      // result should contain both user and token
      // Assuming authRepository.login returns a map or a custom object
      
      // If your authRepository.login returns user only, we need to get token separately
      // Let me know how your authRepository.login works
      
      final user = result; // This might need adjustment based on your repository
      final token = await _getTokenFromStorage(); // Temporary workaround
      
      // Save token to SharedPreferences
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        print('✅ Token saved to SharedPreferences');
      }
      
      print('✅ Login successful for: ${user.email}');
      emit(state.copyWith(
        status: AuthStatus.authenticated, 
        user: user,
        token: token,
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Login error: $e');
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.toString(),
      ));
    }
  }

  // Helper method to get token (temporary)
  Future<String?> _getTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event, 
    Emitter<AuthState> emit
  ) async {
    print('🔐 Register submitted for: ${event.email}');
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await authRepository.register(
        event.name, 
        event.email, 
        event.password,
        event.sectionId
      );
      print('✅ Registration successful');
      emit(state.copyWith(
        status: AuthStatus.registered,
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Registration error: $e');
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event, 
    Emitter<AuthState> emit
  ) async {
    print('🔐 Logout requested');
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      // Clear token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('✅ Token removed from SharedPreferences');
      
      await authRepository.logout();
      print('✅ Logout successful');
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Logout error: $e');
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onUpdateUserSettings(
    UpdateUserSettings event, 
    Emitter<AuthState> emit
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final updatedUser = await authRepository.updateProfile(event.settings);
      emit(state.copyWith(
        status: AuthStatus.authenticated, 
        user: updatedUser,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetAuthState(
    ResetAuthState event, 
    Emitter<AuthState> emit
  ) async {
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
      errorMessage: null,
    ));
  }
}
