import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
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

  bool _isLoadingDepartments = true;
  bool _isLoadingBatches = false;
  bool _isLoadingSections = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;
    setState(() => _isLoadingDepartments = true);
    try {
      final depts = await _orgRepo.getDepartments();
      if (mounted) {
        setState(() {
          _departments = depts;
          _isLoadingDepartments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDepartments = false);
        _showError('Failed to load departments');
      }
    }
  }

  Future<void> _loadBatchesForDepartment(String departmentId) async {
    if (departmentId.isEmpty || !mounted) return;

    setState(() {
      _isLoadingBatches = true;
      _batches = [];
      _selectedBatchId = null;
      _sections = [];
      _selectedSectionId = null;
    });

    try {
      final batches = await _orgRepo.getBatches(departmentId);
      if (mounted) {
        setState(() {
          _batches = batches;
          _isLoadingBatches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBatches = false);
        _showError('Failed to load batches');
      }
    }
  }

  Future<void> _loadSectionsForBatch(String batchId) async {
    if (batchId.isEmpty || !mounted) return;

    setState(() {
      _isLoadingSections = true;
      _sections = [];
      _selectedSectionId = null;
    });

    try {
      final sections = await _orgRepo.getSections(batchId);
      if (mounted) {
        setState(() {
          _sections = sections;
          _isLoadingSections = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSections = false);
        _showError('Failed to load sections');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state.status == AuthStatus.error) {
            _showError(state.errorMessage ?? 'Registration failed');
          } else if (state.status == AuthStatus.registered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please login.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Join your student companion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),

                // Full Name Field
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Abdu',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Name is required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field - UPDATED with @stu.edu validation
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'student@stu.edu',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                        return 'Enter a valid email';
                      }
                      // Student email must be @stu.edu
                      if (!value.toLowerCase().endsWith('@stu.edu')) {
                        return 'Student email must use @stu.edu domain';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Min 6 characters',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Password is required';
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Department Dropdown
                const Text(
                  'Department',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Icon(Icons.business_outlined, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        child: _isLoadingDepartments
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedDepartmentId,
                                  hint: const Text('Select Department'),
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                  items: _departments.map((dept) {
                                    return DropdownMenuItem<String>(
                                      value: dept['id'].toString(),
                                      child: Text(dept['name'] ?? 'Unknown'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null && value != _selectedDepartmentId) {
                                      setState(() {
                                        _selectedDepartmentId = value;
                                        _selectedBatchId = null;
                                        _selectedSectionId = null;
                                      });
                                      _loadBatchesForDepartment(value);
                                    }
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Batch Dropdown
                const Text(
                  'Batch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        child: _isLoadingBatches
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBatchId,
                                  hint: Text(
                                    _selectedDepartmentId == null
                                        ? 'Select department first'
                                        : 'Select Batch',
                                  ),
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                  items: _selectedDepartmentId == null
                                      ? []
                                      : _batches.map((batch) {
                                          return DropdownMenuItem<String>(
                                            value: batch['id'].toString(),
                                            child: Text(batch['name'] ?? 'Unknown'),
                                          );
                                        }).toList(),
                                  onChanged: _selectedDepartmentId == null
                                      ? null
                                      : (value) {
                                          if (value != null && value != _selectedBatchId) {
                                            setState(() {
                                              _selectedBatchId = value;
                                              _selectedSectionId = null;
                                            });
                                            _loadSectionsForBatch(value);
                                          }
                                        },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section Dropdown
                const Text(
                  'Section',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 4),
                        child: Icon(Icons.group_outlined, color: Colors.grey, size: 20),
                      ),
                      Expanded(
                        child: _isLoadingSections
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSectionId,
                                  hint: Text(
                                    _selectedBatchId == null
                                        ? 'Select batch first'
                                        : 'Select Section',
                                  ),
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                                  items: _selectedBatchId == null
                                      ? []
                                      : _sections.map((section) {
                                          return DropdownMenuItem<String>(
                                            value: section['id'].toString(),
                                            child: Text(section['name'] ?? 'Unknown'),
                                          );
                                        }).toList(),
                                  onChanged: _selectedBatchId == null
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() => _selectedSectionId = value);
                                          }
                                        },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Create Account Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isEnabled = state.status != AuthStatus.loading && _selectedSectionId != null;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isEnabled ? _register : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state.status == AuthStatus.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSectionId == null) {
        _showError('Please select department, batch, and section');
        return;
      }

      context.read<AuthBloc>().add(
        RegisterSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          sectionId: _selectedSectionId,
        ),
      );
    }
  }
}
