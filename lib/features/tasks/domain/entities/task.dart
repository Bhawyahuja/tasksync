import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required int id,
    required int userId,
    required String title,
    required bool completed,
    @Default(true) bool isSynced,
  }) = _Task;

  factory Task.local({required String title}) {
    return Task(
      id: -DateTime.now().microsecondsSinceEpoch,
      userId: 1,
      title: title,
      completed: false,
      isSynced: false,
    );
  }

  bool get isLocalOnly => id < 0;
}
