import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/core/repositories/organization_repository.dart';
import 'package:mobile/core/services/local_notification_service.dart';

import 'package:mobile/features/auth/data/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/presentation/auth_bloc.dart';
import 'package:mobile/features/schedule/data/schedule_repository.dart';
import 'package:mobile/features/schedule/presentation/schedule_bloc.dart';
import 'package:mobile/features/assignments/data/assignment_repository.dart';
import 'package:mobile/features/assignments/presentation/assignment_bloc.dart';
import 'package:mobile/features/ai_assistant/data/ai_repository.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_bloc.dart';
import 'package:mobile/features/discussion/data/discussion_repository.dart';
import 'package:mobile/features/discussion/presentation/discussion_bloc.dart';
import 'package:mobile/features/notifications/data/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/notification_bloc.dart';
import 'package:mobile/features/study_materials/data/study_material_repository.dart';
import 'package:mobile/features/study_materials/presentation/study_material_bloc.dart';
import 'package:mobile/features/announcements/data/announcement_repository.dart';
import 'package:mobile/features/announcements/presentation/announcement_bloc.dart';

import 'package:mobile/core/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Logger());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => LocalNotificationService());

  // Theme
  sl.registerLazySingleton(() => ThemeCubit());

  // Get API URL
  final apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.137.102:3000/api';

  print('🌐 API Base URL: $apiBaseUrl');

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 API Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
          '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ API Error: ${error.message}');
        print('📍 URL: ${error.requestOptions.uri}');
        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(sl<AuthInterceptor>());
  sl.registerLazySingleton(() => dio);

  // Features - Auth
  sl.registerLazySingleton(
    () => AuthRemoteDataSource(sl<Dio>(), sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Core Repositories
  sl.registerLazySingleton(() => OrganizationRepository(sl()));

  // Features - Schedule
  sl.registerLazySingleton(() => ScheduleRepository(sl()));
  sl.registerFactory(
    () => ScheduleBloc(
      scheduleRepository: sl(),
      localNotificationService: sl(),
      authBloc: sl(),
    ),
  );

  // Features - Assignments
  sl.registerLazySingleton(() => AssignmentRepository(sl()));
  sl.registerFactory(() => AssignmentBloc(assignmentRepository: sl()));

  // Features - AI Assistant
  sl.registerLazySingleton(() => AIRepository(sl()));
  sl.registerFactory(() => AIBloc(repository: sl()));  // AIBloc registered here

  // Features - Discussion
  sl.registerLazySingleton(() => DiscussionRepository(sl()));
  sl.registerFactory(() => DiscussionBloc(repository: sl()));

  // Features - Notifications
  sl.registerLazySingleton(() => NotificationRepository(sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl()));

  // Features - Study Materials
  sl.registerLazySingleton(() => StudyMaterialRepository(sl()));
  sl.registerFactory(() => StudyMaterialBloc(repository: sl()));

  // Features - Announcements
  sl.registerLazySingleton(() => AnnouncementRepository(sl()));
  sl.registerFactory(() => AnnouncementBloc(announcementRepository: sl()));
}
