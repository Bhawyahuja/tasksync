// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_task_change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingTaskChangeDto _$PendingTaskChangeDtoFromJson(
  Map<String, dynamic> json,
) => _PendingTaskChangeDto(
  action: $enumDecode(_$PendingTaskActionEnumMap, json['action']),
  task: TaskDto.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PendingTaskChangeDtoToJson(
  _PendingTaskChangeDto instance,
) => <String, dynamic>{
  'action': _$PendingTaskActionEnumMap[instance.action]!,
  'task': instance.task,
};

const _$PendingTaskActionEnumMap = {
  PendingTaskAction.add: 'add',
  PendingTaskAction.update: 'update',
  PendingTaskAction.delete: 'delete',
};
