import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> readCachedTasks();

  Future<int> pendingChangeCount();

  Future<List<Task>> fetchTodos();

  Future<RepositoryMutationResult> addTask(Task task);

  Future<RepositoryMutationResult> updateTask(Task task);

  Future<RepositoryMutationResult> deleteTask(Task task);

  Future<SyncReport> syncPendingChanges();
}

class TaskRepositoryException implements Exception {
  const TaskRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'TaskRepositoryException: $message';
}

class SyncReport {
  const SyncReport({required this.syncedCount, required this.pendingCount});

  final int syncedCount;
  final int pendingCount;
}

class RepositoryMutationResult {
  const RepositoryMutationResult({
    required this.tasks,
    required this.pendingCount,
    required this.syncedCount,
    this.error,
  });

  final List<Task> tasks;
  final int pendingCount;
  final int syncedCount;
  final Object? error;

  bool get hasPendingChanges => pendingCount > 0;
}
