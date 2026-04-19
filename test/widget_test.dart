import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasksync/app/task_sync_app.dart';
import 'package:tasksync/core/network/dio_client.dart';
import 'package:tasksync/features/auth/data/auth_local_data_source.dart';
import 'package:tasksync/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:tasksync/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:tasksync/features/tasks/data/repositories/json_placeholder_task_repository.dart';

void main() {
  testWidgets('shows the mock login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();
    final authLocalDataSource = AuthLocalDataSource(preferences);
    final repository = JsonPlaceholderTaskRepository(
      remoteDataSource: TaskRemoteDataSource(dio: DioClient.create()),
      localDataSource: TaskLocalDataSource(preferences),
    );

    await tester.pumpWidget(
      TaskSyncApp(
        taskRepository: repository,
        authLocalDataSource: authLocalDataSource,
      ),
    );

    expect(find.text('TaskSync'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('demo@tasksync.dev'), findsOneWidget);
  });
}
