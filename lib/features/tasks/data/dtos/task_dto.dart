import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_dto.freezed.dart';
part 'task_dto.g.dart';

@freezed
abstract class TaskDto with _$TaskDto {
  const TaskDto._();

  const factory TaskDto({
    @Default(0) int id,
    @Default(1) int userId,
    @Default('') String title,
    @Default(false) bool completed,
    @Default(true) bool isSynced,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);

  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      userId: task.userId,
      title: task.title,
      completed: task.completed,
      isSynced: task.isSynced,
    );
  }

  Task toDomain({bool? isSynced}) {
    return Task(
      id: id,
      userId: userId,
      title: title,
      completed: completed,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toApiJson() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'completed': completed,
    };
  }
}
