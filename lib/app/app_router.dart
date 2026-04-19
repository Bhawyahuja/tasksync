import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/view/login_screen.dart';
import '../features/auth/presentation/view_model/auth_cubit.dart';
import '../features/auth/presentation/view_model/auth_state.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import '../features/tasks/presentation/view/tasks_screen.dart';
import '../features/tasks/presentation/view_model/task_bloc.dart';
import '../features/tasks/presentation/view_model/task_event.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return switch (settings.name) {
          AppRoutes.root => const AuthGate(),
          AppRoutes.login => const LoginScreen(),
          AppRoutes.tasks => const _TasksRoute(),
          _ => const AuthGate(),
        };
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated) {
          return const LoginScreen();
        }

        return const _TasksRoute();
      },
    );
  }
}

class _TasksRoute extends StatelessWidget {
  const _TasksRoute();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (context) =>
          TaskBloc(taskRepository: context.read<TaskRepository>())
            ..add(const TaskLoadRequested()),
      child: const TasksScreen(),
    );
  }
}
