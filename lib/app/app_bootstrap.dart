import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../features/auth/data/auth_local_data_source.dart';
import '../features/tasks/data/datasources/task_local_data_source.dart';
import '../features/tasks/data/datasources/task_remote_data_source.dart';
import '../features/tasks/data/repositories/json_placeholder_task_repository.dart';
import '../features/tasks/domain/repositories/task_repository.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.taskRepository,
    required this.authLocalDataSource,
  });

  final TaskRepository taskRepository;
  final AuthLocalDataSource authLocalDataSource;
}

Future<AppBootstrap> bootstrapApp() async {
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final preferences = await SharedPreferences.getInstance();
  final taskLocalDataSource = TaskLocalDataSource(preferences);
  final taskRemoteDataSource = TaskRemoteDataSource(dio: DioClient.create());

  return AppBootstrap(
    authLocalDataSource: AuthLocalDataSource(preferences),
    taskRepository: JsonPlaceholderTaskRepository(
      remoteDataSource: taskRemoteDataSource,
      localDataSource: taskLocalDataSource,
    ),
  );
}
