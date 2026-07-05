import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_state.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/domain/user_model.dart';
import 'package:mobile/features/auth/presentation/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedRole = 'All Roles';
  String _selectedStatus = 'All Status';
  String _selectedDepartment = 'All Departments';
  String _selectedBatch = 'All Batches';
  String _selectedSection = 'All Sections';

  final List<String> _roles = ['All Roles', 'STUDENT', 'ADMIN'];
  final List<String> _statuses = ['All Status', 'ACTIVE', 'PENDING', 'INACTIVE'];
  final List<String> _departments = ['All Departments', 'Information Technology', 'Computer Science', 'Electrical Engineering'];
  final List<String> _batches = ['All Batches', '2021', '2022', '2023', '2024'];
  final List<String> _sections = ['All Sections', 'Sec A', 'Sec B', 'Sec C'];

  final List<Map<String, dynamic>> _users = [
    {'name': 'Test Student', 'email': 'student@university.edu', 'role': 'STUDENT', 'department': 'N/A', 'batch': 'N/A', 'section': 'N/A', 'status': 'ACTIVE', 'joinDate': '4/23/2026'},
    {'name': 'abdulwahid', 'email': 'abdul@stu.edu', 'role': 'STUDENT', 'department': 'Information Technology', 'batch': '2022', 'section': 'Sec A', 'status': 'ACTIVE', 'joinDate': '4/15/2026'},
    {'name': 'ab', 'email': 'abdi@hu.edu', 'role': 'STUDENT', 'department': 'Information Technology', 'batch': '2022', 'section': 'Sec A', 'status': 'ACTIVE', 'joinDate': '4/13/2026'},
    {'name': 'nnnn', 'email': 'mm@jj.edu', 'role': 'STUDENT', 'department': 'Electrical Engineering', 'batch': '2021', 'section': 'Sec B', 'status': 'PENDING', 'joinDate': '4/13/2026'},
    {'name': 'Admin User', 'email': 'admin@university.edu', 'role': 'ADMIN', 'department': 'N/A', 'batch': 'N/A', 'section': 'N/A', 'status': 'ACTIVE', 'joinDate': '4/12/2026'},
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user['name'].toLowerCase().contains(query) && !user['email'].toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedRole != 'All Roles' && user['role'] != _selectedRole) return false;
      if (_selectedStatus != 'All Status' && user['status'] != _selectedStatus) return false;
      if (_selectedDepartment != 'All Departments' && user['department'] != _selectedDepartment) return false;
      if (_selectedBatch != 'All Batches' && user['batch'] != _selectedBatch) return false;
      if (_selectedSection != 'All Sections' && user['section'] != _selectedSection) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.status != AuthStatus.authenticated || state.user == null || !state.user!.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          });
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        final user = state.user!;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Admin Dashboard'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(icon: const Icon(Icons.person), onPressed: () => _showProfileDialog(context, user)),
              IconButton(icon: const Icon(Icons.logout), onPressed: () => _showLogoutDialog(context)),
            ],
          ),
          drawer: _buildDrawer(context),
          body: _selectedIndex == 1 ? _buildUserManagement() : _buildDashboardOverview(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primary,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)])),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () { setState(() => _selectedIndex = 0); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.people), title: const Text('User Management'), onTap: () { setState(() => _selectedIndex = 1); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.campaign), title: const Text('Announcements'), onTap: () { _showComingSoon(context); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.report), title: const Text('Content Moderation'), onTap: () { _showComingSoon(context); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.menu_book), title: const Text('Study Materials'), onTap: () { _showComingSoon(context); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.forum), title: const Text('Discussions'), onTap: () { _showComingSoon(context); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.calendar_today), title: const Text('Schedule'), onTap: () { _showComingSoon(context); Navigator.pop(context); }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('You have ADMINISTRATOR ACCESS', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Users', '1,234', Icons.people, Colors.blue),
              _buildStatCard('Active Students', '1,156', Icons.school, Colors.green),
              _buildStatCard('Discussions', '89', Icons.forum, Colors.orange),
              _buildStatCard('Reports', '3', Icons.flag, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search names, emails...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('All Roles', _selectedRole, _roles, (v) => setState(() => _selectedRole = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('All Status', _selectedStatus, _statuses, (v) => setState(() => _selectedStatus = v!))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('All Departments', _selectedDepartment, _departments, (v) => setState(() => _selectedDepartment = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('All Batches', _selectedBatch, _batches, (v) => setState(() => _selectedBatch = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('All Sections', _selectedSection, _sections, (v) => setState(() => _selectedSection = v!))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return _buildUserRow(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    Color statusColor = user['status'] == 'ACTIVE' ? Colors.green : (user['status'] == 'PENDING' ? Colors.orange : Colors.red);
    Color roleColor = user['role'] == 'ADMIN' ? Colors.blue : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 2, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(user['email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(user['role'], style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )),
          Expanded(flex: 2, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['department']),
              Text('${user['batch']} • ${user['section']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(user['status'], style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )),
          Expanded(flex: 1, child: Text(user['joinDate'], style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, 'Name', user.name),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', user.email),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.admin_panel_settings, 'Role', user.roleDisplay),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon!')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
