import 'dart:async';

import '../../domain/entities/task.dart';
import 'task_state.dart';

sealed class TaskEvent {
  const TaskEvent();
}

class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested({this.forceRefresh = false, this.completer});

  final bool forceRefresh;
  final Completer<void>? completer;
}

class TaskAdded extends TaskEvent {
  const TaskAdded(this.title);

  final String title;
}

class TaskCompletionToggled extends TaskEvent {
  const TaskCompletionToggled({required this.task, required this.completed});

  final Task task;
  final bool completed;
}

class TaskDeleted extends TaskEvent {
  const TaskDeleted(this.task);

  final Task task;
}

class TaskSearchChanged extends TaskEvent {
  const TaskSearchChanged(this.query);

  final String query;
}

class TaskFilterChanged extends TaskEvent {
  const TaskFilterChanged(this.filter);

  final TaskFilter filter;
}

class TaskSyncRequested extends TaskEvent {
  const TaskSyncRequested({this.silent = false});

  final bool silent;
}
