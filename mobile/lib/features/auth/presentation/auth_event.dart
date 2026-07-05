import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check authentication status when app starts
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email, 
    required this.password
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? sectionId;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    this.sectionId,
  });

  @override
  List<Object?> get props => [name, email, password, sectionId];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class UpdateUserSettings extends AuthEvent {
  final Map<String, dynamic> settings;
  
  const UpdateUserSettings(this.settings);
  
  @override
  List<Object?> get props => [settings];
}

class ResetAuthState extends AuthEvent {
  const ResetAuthState();
}
