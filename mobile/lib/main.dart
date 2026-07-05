import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/injection_container.dart';
import 'package:mobile/core/localization/localization_service.dart';

import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/auth_event.dart';
import 'package:mobile/features/auth/presentation/auth_wrapper.dart';
import 'package:mobile/features/auth/presentation/admin_login_page.dart';
import 'package:mobile/features/schedule/presentation/schedule_bloc.dart';
import 'package:mobile/features/assignments/presentation/assignment_bloc.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_bloc.dart';
import 'package:mobile/features/discussion/presentation/discussion_bloc.dart';
import 'package:mobile/features/notifications/presentation/notification_bloc.dart';
import 'package:mobile/core/services/local_notification_service.dart';
import 'package:mobile/features/study_materials/presentation/study_material_bloc.dart';
import 'package:mobile/features/announcements/presentation/announcement_bloc.dart';
import 'package:mobile/features/announcements/presentation/announcement_event.dart';
import 'package:mobile/core/theme/theme_cubit.dart';
import 'package:mobile/services/firebase_notification_service.dart';

// Global navigator key for AI Bloc to access context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 App starting...');
  
  await dotenv.load(fileName: ".env");
  print('✅ .env loaded');
  
  await di.init();
  print('✅ Dependency injection initialized');
  
  await LocalNotificationService.initialize();
  print('✅ Notification service initialized');

  try {
    await FirebaseNotificationService().initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Firebase Notification service initialized');
  } catch (e) {
    print('⚠️ Firebase not configured yet: $e');
  }
  
  // Initialize localization service
  final localizationService = LocalizationService();
  print('✅ Localization service initialized');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localizationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    print('🏠 MyApp building with locale: ${localizationService.currentLanguage}');
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          print('📦 Creating ThemeCubit');
          return sl<ThemeCubit>();
        }),
        BlocProvider(
          create: (context) {
            print('📦 Creating AuthBloc and checking auth status...');
            return sl<AuthBloc>()..add(const CheckAuthStatus());
          },
        ),
        BlocProvider(create: (context) {
          print('📦 Creating ScheduleBloc');
          return sl<ScheduleBloc>();
        }),
        BlocProvider(create: (context) {
          print('📦 Creating AssignmentBloc');
          return sl<AssignmentBloc>();
        }),
        BlocProvider(create: (context) {
          print('📦 Creating AIBloc');
          return sl<AIBloc>();
        }),
        BlocProvider(create: (context) {
          print('📦 Creating DiscussionBloc');
          return sl<DiscussionBloc>();
        }),
        BlocProvider(create: (context) {
          print('📦 Creating NotificationBloc');
          return sl<NotificationBloc>();
        }),
        BlocProvider(create: (context) {
          print('📦 Creating StudyMaterialBloc');
          return sl<StudyMaterialBloc>();
        }),
        BlocProvider(
          create: (context) {
            print('📦 Creating AnnouncementBloc');
            return sl<AnnouncementBloc>()..add(LoadAnnouncements());
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Student Companion',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            locale: Locale(localizationService.currentLanguage),
            supportedLocales: const [
              Locale('en', ''),
              Locale('am', ''),
              Locale('or', ''),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              print('🔀 Navigating to: ${settings.name}');
              if (settings.name == '/admin-login') {
                return MaterialPageRoute(builder: (context) => const AdminLoginPage());
              }
              return null;
            },
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
