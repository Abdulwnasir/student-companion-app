import 'package:equatable/equatable.dart';
import '../domain/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;  // ADD THIS LINE
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.token,  // ADD THIS
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, token, errorMessage];  // ADD token

  AuthState copyWith({
    AuthStatus? status, 
    User? user, 
    String? token,  // ADD THIS
    String? errorMessage
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,  // ADD THIS
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
