import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_state.freezed.dart';

@freezed
abstract class TaskState with _$TaskState {
  const TaskState._();

  const factory TaskState({
    @Default(TaskStatus.initial) TaskStatus status,
    @Default(<Task>[]) List<Task> tasks,
    @Default('') String searchQuery,
    @Default(TaskFilter.all) TaskFilter filter,
    @Default(false) bool hasPendingChanges,
    @Default(false) bool isSyncing,
    String? message,
  }) = _TaskState;

  List<Task> get filteredTasks {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    return tasks
        .where((task) => filter.matches(task))
        .where((task) {
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return task.title.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  int get completedCount {
    return tasks.where((task) => task.completed).length;
  }
}

enum TaskStatus { initial, loading, success, error }

enum TaskFilter {
  all('All'),
  pending('Pending'),
  completed('Completed');

  const TaskFilter(this.label);

  final String label;

  bool matches(Task task) {
    return switch (this) {
      TaskFilter.all => true,
      TaskFilter.pending => !task.completed,
      TaskFilter.completed => task.completed,
    };
  }
}
