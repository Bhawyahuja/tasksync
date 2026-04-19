import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/auth_local_data_source.dart';
import '../features/auth/presentation/view_model/auth_cubit.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import 'app_colors.dart';
import 'app_router.dart';
import 'app_routes.dart';

class TaskSyncApp extends StatelessWidget {
  const TaskSyncApp({
    required this.taskRepository,
    required this.authLocalDataSource,
    super.key,
  });

  final TaskRepository taskRepository;
  final AuthLocalDataSource authLocalDataSource;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<TaskRepository>.value(value: taskRepository),
        RepositoryProvider<AuthLocalDataSource>.value(
          value: authLocalDataSource,
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(authLocalDataSource),
        child: MaterialApp(
          title: 'TaskSync',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              tertiary: AppColors.tertiary,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
            ),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.root,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
