import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/jobs/bloc/jobs_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/courses/bloc/courses_bloc.dart';
import '../../features/courses/repository/courses_repository.dart';
import '../../features/jobs/repositories/jobs_repository.dart';
import '../../features/messages/bloc/messages_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import '../../features/skill_test/bloc/skill_test_bloc.dart';
import '../../shared/services/api_service.dart';
import '../../shared/services/token_storage.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // Register BLoCs
  _registerBlocs();

  // Register repositories
  _registerRepositories();

  // Register services
  _registerServices();
}

/// Register all BLoCs
void _registerBlocs() {
  // Auth BLoCs
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  // Jobs BLoCs (register first to avoid circular dependency)
  sl.registerLazySingleton<JobsBloc>(
    () => JobsBloc(jobsRepository: sl<JobsRepository>()),
  );

  // Home BLoCs (register after JobsBloc)
  sl.registerLazySingleton<HomeBloc>(() => HomeBloc(jobsBloc: sl<JobsBloc>()));

  // Profile BLoCs
  sl.registerLazySingleton<ProfileBloc>(() => ProfileBloc());

  // Courses BLoCs
  sl.registerFactory<CoursesBloc>(
    () => CoursesBloc(coursesRepository: sl<CoursesRepository>()),
  );

  // Messages BLoCs
  sl.registerLazySingleton<MessagesBloc>(() => MessagesBloc());

  // Settings BLoCs
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc());

  // Skill Test BLoCs
  sl.registerLazySingleton<SkillTestBloc>(() => SkillTestBloc());
}

/// Register all repositories
void _registerRepositories() {
  // Auth repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiService: sl<ApiService>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // Job repositories
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(apiService: sl<ApiService>()),
  );

  // Profile repositories
  // sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());

  // Course repositories
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(apiService: sl<ApiService>()),
  );

  // Message repositories
  // sl.registerLazySingleton<MessageRepository>(() => MessageRepositoryImpl());

  // Settings repositories
  // sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());

  // Skill Test repositories
  // sl.registerLazySingleton<SkillTestRepository>(() => SkillTestRepositoryImpl());
}

/// Register all services
void _registerServices() {
  // API Service
  sl.registerLazySingleton<ApiService>(() {
    final apiService = ApiService();
    // Note: initialize() is called in main.dart after dependencies are registered
    return apiService;
  });

  // Token Storage
  sl.registerLazySingleton<TokenStorage>(() {
    final tokenStorage = TokenStorage.instance;
    tokenStorage.initialize();
    return tokenStorage;
  });
}
