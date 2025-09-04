import 'package:get_it/get_it.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/jobs/bloc/jobs_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/courses/bloc/courses_bloc.dart';
import '../../features/messages/bloc/messages_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import '../../features/skill_test/bloc/skill_test_bloc.dart';

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
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc());

  // Home BLoCs
  sl.registerLazySingleton<HomeBloc>(() => HomeBloc());

  // Jobs BLoCs
  sl.registerLazySingleton<JobsBloc>(() => JobsBloc());

  // Profile BLoCs
  sl.registerLazySingleton<ProfileBloc>(() => ProfileBloc());

  // Courses BLoCs
  sl.registerLazySingleton<CoursesBloc>(() => CoursesBloc());

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
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Job repositories
  // sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl());

  // Profile repositories
  // sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());

  // Course repositories
  // sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl());

  // Message repositories
  // sl.registerLazySingleton<MessageRepository>(() => MessageRepositoryImpl());

  // Settings repositories
  // sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());

  // Skill Test repositories
  // sl.registerLazySingleton<SkillTestRepository>(() => SkillTestRepositoryImpl());
}

/// Register all services
void _registerServices() {
  // Local storage service
  // sl.registerLazySingleton<LocalStorageService>(() => LocalStorageServiceImpl());

  // Network service
  // sl.registerLazySingleton<NetworkService>(() => NetworkServiceImpl());
}
