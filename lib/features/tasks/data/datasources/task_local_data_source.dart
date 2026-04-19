import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dtos/pending_task_change_dto.dart';
import '../dtos/task_dto.dart';

class TaskLocalDataSource {
  TaskLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const String _tasksKey = 'tasksync.cached_tasks';
  static const String _pendingChangesKey = 'tasksync.pending_changes';

  Future<List<TaskDto>> readTasks() async {
    final rawTasks = _preferences.getString(_tasksKey);
    if (rawTasks == null || rawTasks.isEmpty) {
      return <TaskDto>[];
    }

    try {
      final decoded = jsonDecode(rawTasks);
      if (decoded is! List) {
        return <TaskDto>[];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TaskDto.fromJson)
          .toList();
    } on FormatException {
      return <TaskDto>[];
    }
  }

  Future<void> saveTasks(List<TaskDto> tasks) {
    final encoded = jsonEncode(
      tasks.map((task) => task.toJson()).toList(growable: false),
    );
    return _preferences.setString(_tasksKey, encoded);
  }

  Future<List<PendingTaskChangeDto>> readPendingChanges() async {
    final rawChanges = _preferences.getString(_pendingChangesKey);
    if (rawChanges == null || rawChanges.isEmpty) {
      return <PendingTaskChangeDto>[];
    }

    try {
      final decoded = jsonDecode(rawChanges);
      if (decoded is! List) {
        return <PendingTaskChangeDto>[];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PendingTaskChangeDto.fromJson)
          .toList();
    } on FormatException {
      return <PendingTaskChangeDto>[];
    } on ArgumentError {
      return <PendingTaskChangeDto>[];
    }
  }

  Future<void> savePendingChanges(List<PendingTaskChangeDto> changes) {
    final encoded = jsonEncode(
      changes.map((change) => change.toJson()).toList(growable: false),
    );
    return _preferences.setString(_pendingChangesKey, encoded);
  }
}
