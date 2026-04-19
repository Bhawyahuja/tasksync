import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_messages.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'helpers/connectivity_controller.dart';
import 'helpers/task_list_mutations.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required TaskRepository taskRepository,
    ConnectivityController? connectivityController,
  }) : _taskRepository = taskRepository,
       _connectivityController =
           connectivityController ?? ConnectivityController(),
       super(const TaskState()) {
    on<TaskLoadRequested>(
      (event, emit) =>
          _runTaskOperation(() => _onTaskLoadRequested(event, emit)),
    );
    on<TaskAdded>(
      (event, emit) => _runTaskOperation(() => _onTaskAdded(event, emit)),
    );
    on<TaskCompletionToggled>(
      (event, emit) =>
          _runTaskOperation(() => _onTaskCompletionToggled(event, emit)),
    );
    on<TaskDeleted>(
      (event, emit) => _runTaskOperation(() => _onTaskDeleted(event, emit)),
    );
    on<TaskSearchChanged>(_onTaskSearchChanged);
    on<TaskFilterChanged>(_onTaskFilterChanged);
    on<TaskSyncRequested>(
      (event, emit) =>
          _runTaskOperation(() => _onTaskSyncRequested(event, emit)),
    );

    _connectivitySubscription = _connectivityController.listenWhenOnline(
      _syncSilently,
    );
  }

  final TaskRepository _taskRepository;
  final ConnectivityController _connectivityController;
  late final StreamSubscription<dynamic> _connectivitySubscription;
  Future<void> _lastTaskOperation = Future<void>.value();
  bool _syncInFlight = false;

  Future<void> _runTaskOperation(Future<void> Function() operation) {
    final currentOperation = _lastTaskOperation
        .catchError((Object _) {})
        .then((_) => operation());
    _lastTaskOperation = currentOperation.catchError((Object _) {});
    return currentOperation;
  }

  Future<void> _onTaskLoadRequested(
    TaskLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final cachedTasks = await _taskRepository.readCachedTasks();
      final pendingCount = await _taskRepository.pendingChangeCount();
      emit(
        state.copyWith(
          status: TaskStatus.loading,
          tasks: cachedTasks,
          hasPendingChanges: pendingCount > 0,
          isSyncing: false,
          message: null,
        ),
      );

      try {
        await _taskRepository.syncPendingChanges();
        final tasks = await _taskRepository.fetchTodos();
        final remainingPendingCount = await _taskRepository
            .pendingChangeCount();
        emit(
          state.copyWith(
            status: TaskStatus.success,
            tasks: tasks,
            hasPendingChanges: remainingPendingCount > 0,
            isSyncing: false,
            message: null,
          ),
        );
      } catch (_) {
        final remainingPendingCount = await _taskRepository
            .pendingChangeCount();
        if (cachedTasks.isNotEmpty) {
          emit(
            state.copyWith(
              status: TaskStatus.error,
              tasks: cachedTasks,
              hasPendingChanges: remainingPendingCount > 0,
              isSyncing: false,
              message: AppMessages.cachedTodos,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: TaskStatus.error,
            tasks: const <Task>[],
            hasPendingChanges: remainingPendingCount > 0,
            isSyncing: false,
            message: AppMessages.loadFailed,
          ),
        );
      }
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onTaskAdded(TaskAdded event, Emitter<TaskState> emit) async {
    final title = event.title.trim();
    if (title.isEmpty) {
      return;
    }

    final optimisticTask = Task.local(title: title);
    emit(
      state.copyWith(
        status: TaskStatus.success,
        tasks: state.tasks.withAdded(optimisticTask),
        hasPendingChanges: true,
        isSyncing: true,
        message: null,
      ),
    );

    final result = await _taskRepository.addTask(optimisticTask);
    _emitMutationResult(emit, result, _TaskMutation.add);
  }

  Future<void> _onTaskCompletionToggled(
    TaskCompletionToggled event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = event.task.copyWith(
      completed: event.completed,
      isSynced: false,
    );

    emit(
      state.copyWith(
        status: TaskStatus.success,
        tasks: state.tasks.withUpdated(updatedTask),
        hasPendingChanges: true,
        isSyncing: true,
        message: null,
      ),
    );

    final result = await _taskRepository.updateTask(updatedTask);
    _emitMutationResult(emit, result, _TaskMutation.update);
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TaskStatus.success,
        tasks: state.tasks.without(event.task),
        hasPendingChanges: true,
        isSyncing: true,
        message: null,
      ),
    );

    final result = await _taskRepository.deleteTask(event.task);
    _emitMutationResult(emit, result, _TaskMutation.delete);
  }

  void _onTaskSearchChanged(TaskSearchChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: event.query, message: null));
  }

  void _onTaskFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(filter: event.filter, message: null));
  }

  Future<void> _onTaskSyncRequested(
    TaskSyncRequested event,
    Emitter<TaskState> emit,
  ) async {
    if (_syncInFlight) {
      return;
    }

    final pendingCount = await _taskRepository.pendingChangeCount();
    if (pendingCount == 0) {
      if (!event.silent) {
        emit(
          state.copyWith(
            hasPendingChanges: false,
            isSyncing: false,
            message: AppMessages.noPendingChanges,
          ),
        );
      }
      return;
    }

    _syncInFlight = true;
    if (!event.silent) {
      emit(
        state.copyWith(
          isSyncing: true,
          hasPendingChanges: true,
          message: AppMessages.syncStarted,
        ),
      );
    }

    try {
      final report = await _taskRepository.syncPendingChanges();
      final hasPendingChanges = report.pendingCount > 0;
      if (event.silent) {
        _emitSilentSyncStateIfNeeded(emit, hasPendingChanges);
        return;
      }

      final tasks = await _taskRepository.readCachedTasks();
      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: tasks,
          hasPendingChanges: hasPendingChanges,
          isSyncing: false,
          message: AppMessages.syncCompleted,
        ),
      );
    } catch (_) {
      if (event.silent) {
        _emitSilentSyncStateIfNeeded(emit, true);
        return;
      }

      final tasks = await _taskRepository.readCachedTasks();
      final remainingPendingCount = await _taskRepository.pendingChangeCount();
      emit(
        state.copyWith(
          status: TaskStatus.error,
          tasks: tasks,
          hasPendingChanges: remainingPendingCount > 0,
          isSyncing: false,
          message: AppMessages.syncFailed,
        ),
      );
    } finally {
      _syncInFlight = false;
    }
  }

  void _emitMutationResult(
    Emitter<TaskState> emit,
    RepositoryMutationResult result,
    _TaskMutation mutation,
  ) {
    emit(
      state.copyWith(
        status: TaskStatus.success,
        tasks: result.tasks,
        hasPendingChanges: result.hasPendingChanges,
        isSyncing: false,
        message: result.error == null
            ? mutation.successMessage
            : AppMessages.savedOffline,
      ),
    );
  }

  void _emitSilentSyncStateIfNeeded(
    Emitter<TaskState> emit,
    bool hasPendingChanges,
  ) {
    if (state.hasPendingChanges == hasPendingChanges && !state.isSyncing) {
      return;
    }

    emit(
      state.copyWith(
        hasPendingChanges: hasPendingChanges,
        isSyncing: false,
        message: null,
      ),
    );
  }

  void _syncSilently() {
    add(const TaskSyncRequested(silent: true));
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}

enum _TaskMutation {
  add(AppMessages.taskAdded),
  update(AppMessages.taskUpdated),
  delete(AppMessages.taskDeleted);

  const _TaskMutation(this.successMessage);

  final String successMessage;
}
