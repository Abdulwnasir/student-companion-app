import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/localization_service.dart';
import '../../../core/localization/language_switcher.dart';
import '../../../core/localization/translated_text.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../schedule/presentation/schedule_page.dart';
import '../../assignments/presentation/assignment_list_page.dart';
import '../../ai_assistant/presentation/ai_assistant_page.dart';
import 'package:mobile/features/discussion/presentation/discussion_group_list_page.dart';
import 'package:mobile/features/auth/presentation/settings_page.dart';
import 'package:mobile/features/common/presentation/about_page.dart';
import 'package:mobile/features/study_materials/presentation/study_material_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/theme_cubit.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static MainPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainPageState>();
  }

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const SchedulePage(),
    const AssignmentListPage(),
    const AIAssistantPage(),
    const DiscussionGroupListPage(),
    const StudyMaterialListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.translate('logout')),
        content: Text(localizationService.translate('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizationService.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizationService.translate('logout'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Navigator.pop(context);
      context.read<AuthBloc>().add(LogoutRequested());
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.translate('logged_out')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('app_name'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, localizationService),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: localizationService.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: localizationService.translate('schedule'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: localizationService.translate('tasks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome_outlined),
            activeIcon: const Icon(Icons.auto_awesome),
            label: localizationService.translate('ai_chat_short'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum_outlined),
            activeIcon: const Icon(Icons.forum),
            label: localizationService.translate('discuss'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: localizationService.translate('materials'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, LocalizationService localizationService) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                TranslatedText(
                  'app_name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TranslatedText(
                  'your_academic_assistant',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const TranslatedText('home'),
            selected: _selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const TranslatedText('schedule'),
            selected: _selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const TranslatedText('tasks'),
            selected: _selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const TranslatedText('ai_chat'),
            selected: _selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const TranslatedText('discussion'),
            selected: _selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const TranslatedText('study_materials'),
            selected: _selectedIndex == 5,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 5;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const TranslatedText('settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const LanguageSwitcher(isSidebar: true),
          const Divider(),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.themeMode == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                title: Text(
                  isDark 
                    ? localizationService.translate('light_theme')
                    : localizationService.translate('dark_theme'),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
                onTap: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const TranslatedText('about'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
