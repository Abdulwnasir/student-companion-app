import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/custom_text_field.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/injection_container.dart';
import 'package:mobile/core/repositories/organization_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _orgRepo = sl<OrganizationRepository>();
  List<dynamic> _departments = [];
  List<dynamic> _batches = [];
  List<dynamic> _sections = [];

  String? _selectedDepartmentId;
  String? _selectedBatchId;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final depts = await _orgRepo.getDepartments();
    setState(() => _departments = depts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated &&
              state.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please login.'),
              ),
            );
            Navigator.pop(context);
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Registration failed'),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join your student companion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Enter your name',
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email Address',
                  hint: 'student@university.edu',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && RegExp(r'@.*\.edu$').hasMatch(v)
                      ? null
                      : 'Enter a valid university email (.edu)',
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Password',
                  hint: 'Min 6 characters',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => v != null && v.length >= 6
                      ? null
                      : 'Password must be at least 6 characters',
                ),
                _buildOrganizationDropdowns(),
                const SizedBox(height: 40),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedSectionId == null)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Please complete your Academic Placement selection below',
                              style: TextStyle(
                                color: AppTheme.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ElevatedButton(
                          onPressed:
                              state.status == AuthStatus.loading ||
                                  _selectedSectionId == null
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      RegisterSubmitted(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        sectionId: _selectedSectionId!,
                                      ),
                                    );
                                  }
                                },
                          child: state.status == AuthStatus.loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Create Account'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartmentId,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          items: _departments.map<DropdownMenuItem<String>>((dept) {
            return DropdownMenuItem<String>(
              value: dept['id'],
              child: Text(dept['name']),
            );
          }).toList(),
          onChanged: (value) async {
            setState(() {
              _selectedDepartmentId = value;
              _selectedBatchId = null;
              _selectedSectionId = null;
              _batches = [];
              _sections = [];
            });
            if (value != null) {
              final batches = await _orgRepo.getBatches(value);
              setState(() => _batches = batches);
            }
          },
          validator: (v) => v == null ? 'Select Department' : null,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedBatchId,
          decoration: const InputDecoration(
            labelText: 'Batch',
            prefixIcon: Icon(Icons.calendar_today_outlined),
          ),
          items: _batches.map<DropdownMenuItem<String>>((batch) {
            return DropdownMenuItem<String>(
              value: batch['id'],
              child: Text(batch['name']),
            );
          }).toList(),
          onChanged: (value) async {
            setState(() {
              _selectedBatchId = value;
              _selectedSectionId = null;
              _sections = [];
            });
            if (value != null) {
              final sections = await _orgRepo.getSections(value);
              setState(() => _sections = sections);
            }
          },
          validator: (v) => v == null ? 'Select Batch' : null,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedSectionId,
          decoration: const InputDecoration(
            labelText: 'Section',
            prefixIcon: Icon(Icons.groups_outlined),
          ),
          items: _sections.map<DropdownMenuItem<String>>((sec) {
            return DropdownMenuItem<String>(
              value: sec['id'],
              child: Text(sec['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSectionId = value);
          },
          validator: (v) => v == null ? 'Select Section' : null,
        ),
      ],
    );
  }
}
