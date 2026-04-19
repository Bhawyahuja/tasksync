// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_task_change_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingTaskChangeDto {

 PendingTaskAction get action; TaskDto get task;
/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingTaskChangeDtoCopyWith<PendingTaskChangeDto> get copyWith => _$PendingTaskChangeDtoCopyWithImpl<PendingTaskChangeDto>(this as PendingTaskChangeDto, _$identity);

  /// Serializes this PendingTaskChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingTaskChangeDto&&(identical(other.action, action) || other.action == action)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,task);

@override
String toString() {
  return 'PendingTaskChangeDto(action: $action, task: $task)';
}


}

/// @nodoc
abstract mixin class $PendingTaskChangeDtoCopyWith<$Res>  {
  factory $PendingTaskChangeDtoCopyWith(PendingTaskChangeDto value, $Res Function(PendingTaskChangeDto) _then) = _$PendingTaskChangeDtoCopyWithImpl;
@useResult
$Res call({
 PendingTaskAction action, TaskDto task
});


$TaskDtoCopyWith<$Res> get task;

}
/// @nodoc
class _$PendingTaskChangeDtoCopyWithImpl<$Res>
    implements $PendingTaskChangeDtoCopyWith<$Res> {
  _$PendingTaskChangeDtoCopyWithImpl(this._self, this._then);

  final PendingTaskChangeDto _self;
  final $Res Function(PendingTaskChangeDto) _then;

/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? task = null,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PendingTaskAction,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as TaskDto,
  ));
}
/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskDtoCopyWith<$Res> get task {
  
  return $TaskDtoCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}


/// Adds pattern-matching-related methods to [PendingTaskChangeDto].
extension PendingTaskChangeDtoPatterns on PendingTaskChangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingTaskChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingTaskChangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingTaskChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _PendingTaskChangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingTaskChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PendingTaskChangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PendingTaskAction action,  TaskDto task)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingTaskChangeDto() when $default != null:
return $default(_that.action,_that.task);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PendingTaskAction action,  TaskDto task)  $default,) {final _that = this;
switch (_that) {
case _PendingTaskChangeDto():
return $default(_that.action,_that.task);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PendingTaskAction action,  TaskDto task)?  $default,) {final _that = this;
switch (_that) {
case _PendingTaskChangeDto() when $default != null:
return $default(_that.action,_that.task);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingTaskChangeDto implements PendingTaskChangeDto {
  const _PendingTaskChangeDto({required this.action, required this.task});
  factory _PendingTaskChangeDto.fromJson(Map<String, dynamic> json) => _$PendingTaskChangeDtoFromJson(json);

@override final  PendingTaskAction action;
@override final  TaskDto task;

/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingTaskChangeDtoCopyWith<_PendingTaskChangeDto> get copyWith => __$PendingTaskChangeDtoCopyWithImpl<_PendingTaskChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingTaskChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingTaskChangeDto&&(identical(other.action, action) || other.action == action)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,task);

@override
String toString() {
  return 'PendingTaskChangeDto(action: $action, task: $task)';
}


}

/// @nodoc
abstract mixin class _$PendingTaskChangeDtoCopyWith<$Res> implements $PendingTaskChangeDtoCopyWith<$Res> {
  factory _$PendingTaskChangeDtoCopyWith(_PendingTaskChangeDto value, $Res Function(_PendingTaskChangeDto) _then) = __$PendingTaskChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 PendingTaskAction action, TaskDto task
});


@override $TaskDtoCopyWith<$Res> get task;

}
/// @nodoc
class __$PendingTaskChangeDtoCopyWithImpl<$Res>
    implements _$PendingTaskChangeDtoCopyWith<$Res> {
  __$PendingTaskChangeDtoCopyWithImpl(this._self, this._then);

  final _PendingTaskChangeDto _self;
  final $Res Function(_PendingTaskChangeDto) _then;

/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? task = null,}) {
  return _then(_PendingTaskChangeDto(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as PendingTaskAction,task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as TaskDto,
  ));
}

/// Create a copy of PendingTaskChangeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskDtoCopyWith<$Res> get task {
  
  return $TaskDtoCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}

// dart format on
