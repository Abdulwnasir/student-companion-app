import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/features/auth/presentation/login_page.dart';
import 'package:mobile/features/dashboard/presentation/main_page.dart';
import 'package:mobile/features/admin/presentation/admin_dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.authenticated && state.user != null) {
          final user = state.user!;
          // Admin goes to Admin Dashboard, Student goes to Main App
          if (user.isAdmin) {
            return const AdminDashboardPage();
          } else {
            return const MainPage();
          }
        }

        return const LoginPage();
      },
    );
  }
}
