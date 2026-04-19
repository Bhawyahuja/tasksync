import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_dto.dart';

part 'pending_task_change_dto.freezed.dart';
part 'pending_task_change_dto.g.dart';

enum PendingTaskAction { add, update, delete }

@freezed
abstract class PendingTaskChangeDto with _$PendingTaskChangeDto {
  const factory PendingTaskChangeDto({
    required PendingTaskAction action,
    required TaskDto task,
  }) = _PendingTaskChangeDto;

  factory PendingTaskChangeDto.fromJson(Map<String, dynamic> json) =>
      _$PendingTaskChangeDtoFromJson(json);
}
