import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/domain/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthRepository authRepository;
    late AuthBloc authBloc;

    setUp(() {
      authRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: authRepository);
    });

    // Initial state
    test('initial state is AuthState()', () {
      expect(authBloc.state, const AuthState());
    });

    // Login Success
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when LoginSubmitted is successful',
      build: () {
        when(() => authRepository.login(any(), any()))
            .thenAnswer((_) async => const User(id: '123', email: 'test@example.com', name: 'Test User', role: UserRole.student, isApproved: true));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(email: 'test@example.com', password: 'password')),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: User(id: '123', email: 'test@example.com', name: 'Test User', role: UserRole.student, isApproved: true)),
      ],
    );

    // Login Failure
    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when LoginSubmitted fails',
      build: () {
        when(() => authRepository.login(any(), any())).thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(email: 'test@example.com', password: 'password')),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.error, errorMessage: 'Exception: Login failed'),
      ],
    );

    // Logout
    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when LogoutRequested is added',
      build: () {
        when(() => authRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );
  });
}
