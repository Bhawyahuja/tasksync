import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasksync/core/network/dio_client.dart';
import 'package:tasksync/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:tasksync/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:tasksync/features/tasks/data/dtos/pending_task_change_dto.dart';
import 'package:tasksync/features/tasks/data/dtos/task_dto.dart';
import 'package:tasksync/features/tasks/data/repositories/json_placeholder_task_repository.dart';
import 'package:tasksync/features/tasks/domain/entities/task.dart';

void main() {
  test(
    'deleteTask handles an empty cache without fixed-length list errors',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final preferences = await SharedPreferences.getInstance();
      final repository = JsonPlaceholderTaskRepository(
        remoteDataSource: TaskRemoteDataSource(dio: DioClient.create()),
        localDataSource: TaskLocalDataSource(preferences),
      );

      final result = await repository.deleteTask(
        Task.local(title: 'Local only'),
      );

      expect(result.tasks, isEmpty);
      expect(result.pendingCount, 0);
    },
  );

  test('sync treats JSONPlaceholder fake ids as local only', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();
    final localDataSource = TaskLocalDataSource(preferences);
    final task = const TaskDto(
      id: 201,
      userId: 1,
      title: 'Created by JSONPlaceholder',
      completed: true,
      isSynced: false,
    );
    await localDataSource.saveTasks(<TaskDto>[task]);
    await localDataSource.savePendingChanges(<PendingTaskChangeDto>[
      PendingTaskChangeDto(action: PendingTaskAction.add, task: task),
      PendingTaskChangeDto(action: PendingTaskAction.update, task: task),
    ]);

    final repository = JsonPlaceholderTaskRepository(
      remoteDataSource: TaskRemoteDataSource(
        dio: _dioWithRequestHandler((options, handler) {
          fail('Fake JSONPlaceholder ids should not be sent back to the API.');
        }),
      ),
      localDataSource: localDataSource,
    );

    final report = await repository.syncPendingChanges();
    final cachedTasks = await localDataSource.readTasks();

    expect(report.pendingCount, 0);
    expect(cachedTasks.single.isSynced, isTrue);
  });

  test('sync clears delete when JSONPlaceholder blocks it', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final preferences = await SharedPreferences.getInstance();
    final localDataSource = TaskLocalDataSource(preferences);
    const task = TaskDto(id: 4, userId: 1, title: 'Remote todo');
    await localDataSource.saveTasks(const <TaskDto>[]);
    await localDataSource.savePendingChanges(const <PendingTaskChangeDto>[
      PendingTaskChangeDto(action: PendingTaskAction.delete, task: task),
    ]);

    final repository = JsonPlaceholderTaskRepository(
      remoteDataSource: TaskRemoteDataSource(
        dio: _dioWithRequestHandler((options, handler) {
          expect(options.method, 'DELETE');
          expect(options.path, '/todos/4');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 403,
              data: '<html>Cloudflare</html>',
            ),
          );
        }),
      ),
      localDataSource: localDataSource,
    );

    final report = await repository.syncPendingChanges();
    final pendingChanges = await localDataSource.readPendingChanges();

    expect(report.pendingCount, 0);
    expect(pendingChanges, isEmpty);
  });
}

Dio _dioWithRequestHandler(
  void Function(RequestOptions options, RequestInterceptorHandler handler)
  onRequest,
) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      validateStatus: (_) => true,
    ),
  )..interceptors.add(InterceptorsWrapper(onRequest: onRequest));
}
