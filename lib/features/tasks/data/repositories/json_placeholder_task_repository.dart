import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../dtos/pending_task_change_dto.dart';
import '../dtos/task_dto.dart';

class JsonPlaceholderTaskRepository implements TaskRepository {
  const JsonPlaceholderTaskRepository({
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  Future<List<Task>> readCachedTasks() async {
    return (await _localDataSource.readTasks())
        .map((task) => task.toDomain())
        .toList(growable: false);
  }

  @override
  Future<int> pendingChangeCount() async {
    return (await _localDataSource.readPendingChanges()).length;
  }

  @override
  Future<List<Task>> fetchTodos() async {
    final remoteTasks = await _remoteDataSource.getTodos();
    final cachedTasks = await _localDataSource.readTasks();
    final pendingChanges = await _localDataSource.readPendingChanges();
    final mergedTasks = _applyPendingChanges(
      _mergeRemoteWithCachedTasks(remoteTasks, cachedTasks, pendingChanges),
      pendingChanges,
    );
    await _localDataSource.saveTasks(mergedTasks);
    return mergedTasks.map((task) => task.toDomain()).toList(growable: false);
  }

  @override
  Future<RepositoryMutationResult> addTask(Task task) async {
    final taskDto = TaskDto.fromDomain(task);
    final tasks = await _localDataSource.readTasks();
    await _localDataSource.saveTasks(<TaskDto>[taskDto, ...tasks]);
    await _enqueueChange(
      PendingTaskChangeDto(action: PendingTaskAction.add, task: taskDto),
    );
    return _syncAfterMutation();
  }

  @override
  Future<RepositoryMutationResult> updateTask(Task task) async {
    final pendingTask = TaskDto.fromDomain(task.copyWith(isSynced: false));
    final tasks = await _localDataSource.readTasks();
    final index = tasks.indexWhere((cachedTask) => cachedTask.id == task.id);

    if (index == -1) {
      await _localDataSource.saveTasks(<TaskDto>[pendingTask, ...tasks]);
    } else {
      tasks[index] = pendingTask;
      await _localDataSource.saveTasks(tasks);
    }

    await _enqueueChange(
      PendingTaskChangeDto(action: PendingTaskAction.update, task: pendingTask),
    );
    return _syncAfterMutation();
  }

  @override
  Future<RepositoryMutationResult> deleteTask(Task task) async {
    final taskDto = TaskDto.fromDomain(task);
    final tasks = await _localDataSource.readTasks();
    tasks.removeWhere((cachedTask) => cachedTask.id == task.id);
    await _localDataSource.saveTasks(tasks);
    await _enqueueChange(
      PendingTaskChangeDto(action: PendingTaskAction.delete, task: taskDto),
    );
    return _syncAfterMutation();
  }

  @override
  Future<SyncReport> syncPendingChanges() async {
    final pendingChanges = await _localDataSource.readPendingChanges();
    if (pendingChanges.isEmpty) {
      return const SyncReport(syncedCount: 0, pendingCount: 0);
    }

    final tasks = await _localDataSource.readTasks();
    var syncedCount = 0;

    for (var index = 0; index < pendingChanges.length; index += 1) {
      final change = pendingChanges[index];

      try {
        switch (change.action) {
          case PendingTaskAction.add:
            await _syncAdd(change.task, tasks);
          case PendingTaskAction.update:
            await _syncUpdate(change.task, tasks);
          case PendingTaskAction.delete:
            await _syncDelete(change.task);
        }
        syncedCount += 1;
      } catch (error) {
        _logSyncFailure(change, error);
        final remainingChanges = <PendingTaskChangeDto>[
          change,
          ...pendingChanges.skip(index + 1),
        ];
        await _localDataSource.saveTasks(tasks);
        await _localDataSource.savePendingChanges(remainingChanges);
        throw TaskRepositoryException(
          'Some changes could not be synced yet.',
          cause: error,
        );
      }
    }

    await _localDataSource.saveTasks(tasks);
    await _localDataSource.savePendingChanges(const <PendingTaskChangeDto>[]);
    return SyncReport(syncedCount: syncedCount, pendingCount: 0);
  }

  Future<RepositoryMutationResult> _syncAfterMutation() async {
    var syncedCount = 0;
    Object? error;

    try {
      final report = await syncPendingChanges();
      syncedCount = report.syncedCount;
    } catch (syncError) {
      error = syncError;
    }

    final tasks = await readCachedTasks();
    final pendingCount = await pendingChangeCount();
    return RepositoryMutationResult(
      tasks: tasks,
      pendingCount: pendingCount,
      syncedCount: syncedCount,
      error: error,
    );
  }

  Future<void> _syncAdd(TaskDto task, List<TaskDto> tasks) async {
    if (_isFakeJsonPlaceholderTodo(task.id)) {
      _markTaskSynced(task.id, tasks);
      return;
    }

    await _remoteDataSource.createTodo(task);
    _markTaskSynced(task.id, tasks);
  }

  void _markTaskSynced(int taskId, List<TaskDto> tasks) {
    final index = tasks.indexWhere((cachedTask) => cachedTask.id == taskId);
    if (index == -1) {
      return;
    }

    tasks[index] = tasks[index].copyWith(isSynced: true);
  }

  Future<void> _syncUpdate(TaskDto task, List<TaskDto> tasks) async {
    if (!_isPersistedRemoteTodo(task.id)) {
      final localIndex = tasks.indexWhere(
        (cachedTask) => cachedTask.id == task.id,
      );
      if (localIndex != -1) {
        tasks[localIndex] = tasks[localIndex].copyWith(isSynced: true);
      }
      return;
    }

    final syncedTask = await _remoteDataSource.updateTodo(task);
    final index = tasks.indexWhere((cachedTask) => cachedTask.id == task.id);
    if (index == -1) {
      return;
    }

    tasks[index] = tasks[index].copyWith(
      title: syncedTask.title,
      completed: syncedTask.completed,
      isSynced: true,
    );
  }

  Future<void> _syncDelete(TaskDto task) async {
    if (!_isPersistedRemoteTodo(task.id)) {
      return;
    }

    try {
      await _remoteDataSource.deleteTodo(task.id);
    } on ApiException catch (error) {
      if (error.statusCode == 403) {
        debugPrint(
          '[Sync] JSONPlaceholder blocked DELETE for todo ${task.id}; '
          'keeping local optimistic delete.',
        );
        return;
      }
      rethrow;
    }
  }

  Future<void> _enqueueChange(PendingTaskChangeDto change) async {
    final pendingChanges = <PendingTaskChangeDto>[
      ...await _localDataSource.readPendingChanges(),
    ];

    switch (change.action) {
      case PendingTaskAction.add:
        pendingChanges.removeWhere(
          (pendingChange) => pendingChange.task.id == change.task.id,
        );
        pendingChanges.add(change);
      case PendingTaskAction.update:
        final pendingAddIndex = pendingChanges.indexWhere(
          (pendingChange) =>
              pendingChange.action == PendingTaskAction.add &&
              pendingChange.task.id == change.task.id,
        );

        if (pendingAddIndex == -1) {
          pendingChanges.removeWhere(
            (pendingChange) =>
                pendingChange.action == PendingTaskAction.update &&
                pendingChange.task.id == change.task.id,
          );
          pendingChanges.add(change);
        } else {
          pendingChanges[pendingAddIndex] = PendingTaskChangeDto(
            action: PendingTaskAction.add,
            task: change.task,
          );
        }
      case PendingTaskAction.delete:
        final hadUnsyncedAdd = pendingChanges.any(
          (pendingChange) =>
              pendingChange.action == PendingTaskAction.add &&
              pendingChange.task.id == change.task.id,
        );
        pendingChanges.removeWhere(
          (pendingChange) => pendingChange.task.id == change.task.id,
        );

        if (!hadUnsyncedAdd && _isPersistedRemoteTodo(change.task.id)) {
          pendingChanges.add(change);
        }
    }

    await _localDataSource.savePendingChanges(pendingChanges);
  }

  List<TaskDto> _mergeRemoteWithCachedTasks(
    List<TaskDto> remoteTasks,
    List<TaskDto> cachedTasks,
    List<PendingTaskChangeDto> pendingChanges,
  ) {
    final remoteIds = remoteTasks.map((task) => task.id).toSet();
    final pendingDeleteIds = pendingChanges
        .where((change) => change.action == PendingTaskAction.delete)
        .map((change) => change.task.id)
        .toSet();

    final localOnlyTasks = cachedTasks.where((task) {
      return !remoteIds.contains(task.id) &&
          !pendingDeleteIds.contains(task.id);
    });

    return <TaskDto>[
      ...localOnlyTasks,
      ...remoteTasks.map((task) => task.copyWith(isSynced: true)),
    ];
  }

  List<TaskDto> _applyPendingChanges(
    List<TaskDto> remoteTasks,
    List<PendingTaskChangeDto> pendingChanges,
  ) {
    final tasks = remoteTasks
        .map((task) => task.copyWith(isSynced: true))
        .toList(growable: true);

    for (final pendingChange in pendingChanges) {
      switch (pendingChange.action) {
        case PendingTaskAction.add:
          final index = tasks.indexWhere(
            (task) => task.id == pendingChange.task.id,
          );
          if (index == -1) {
            tasks.insert(0, pendingChange.task.copyWith(isSynced: false));
          } else {
            tasks[index] = pendingChange.task.copyWith(isSynced: false);
          }
        case PendingTaskAction.update:
          final index = tasks.indexWhere(
            (task) => task.id == pendingChange.task.id,
          );
          if (index == -1) {
            tasks.insert(0, pendingChange.task.copyWith(isSynced: false));
          } else {
            tasks[index] = pendingChange.task.copyWith(isSynced: false);
          }
        case PendingTaskAction.delete:
          tasks.removeWhere((task) => task.id == pendingChange.task.id);
      }
    }

    return tasks;
  }

  bool _isPersistedRemoteTodo(int id) {
    return id > 0 && id <= 200;
  }

  bool _isFakeJsonPlaceholderTodo(int id) {
    return id > 200;
  }

  void _logSyncFailure(PendingTaskChangeDto change, Object error) {
    debugPrint(
      '[Sync] Failed ${change.action.name} for todo ${change.task.id}: $error',
    );
  }
}
