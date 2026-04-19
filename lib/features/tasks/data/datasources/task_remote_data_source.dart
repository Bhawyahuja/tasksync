import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../dtos/task_dto.dart';

class TaskRemoteDataSource {
  const TaskRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<TaskDto>> getTodos() async {
    final response = await _dio.get<dynamic>('/todos');
    _ensureSuccess(response, expectedStatuses: <int>{200});

    final data = response.data;
    if (data is! List) {
      throw const ApiException('Unexpected todo list response.');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(TaskDto.fromJson)
        .toList(growable: false);
  }

  Future<TaskDto> createTodo(TaskDto task) async {
    final response = await _dio.post<dynamic>('/todos', data: task.toApiJson());
    _ensureSuccess(response, expectedStatuses: <int>{200, 201});

    return TaskDto.fromJson(<String, dynamic>{
      ...task.toJson(),
      ..._decodeObject(response.data),
      'isSynced': true,
    });
  }

  Future<TaskDto> updateTodo(TaskDto task) async {
    final response = await _dio.patch<dynamic>(
      '/todos/${task.id}',
      data: task.toApiJson(),
    );
    _ensureSuccess(response, expectedStatuses: <int>{200});

    return TaskDto.fromJson(<String, dynamic>{
      ...task.toJson(),
      ..._decodeObject(response.data),
      'isSynced': true,
    });
  }

  Future<void> deleteTodo(int id) async {
    final response = await _dio.delete<dynamic>('/todos/$id');
    _ensureSuccess(response, expectedStatuses: <int>{200, 204});
  }

  void close() {
    _dio.close();
  }

  Map<String, dynamic> _decodeObject(dynamic data) {
    if (data == null || data == '') {
      return <String, dynamic>{};
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    return <String, dynamic>{};
  }

  void _ensureSuccess(
    Response<dynamic> response, {
    required Set<int> expectedStatuses,
  }) {
    final statusCode = response.statusCode;
    if (statusCode != null && expectedStatuses.contains(statusCode)) {
      return;
    }

    throw ApiException(
      'Request failed while talking to JSONPlaceholder.',
      statusCode: statusCode,
    );
  }
}
