import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract final class DioClient {
  static Dio create({String baseUrl = 'https://jsonplaceholder.typicode.com'}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: _headers,
        validateStatus: (_) => true,
      ),
    )..interceptors.add(_ApiLogInterceptor());
  }

  static const Map<String, String> _headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };
}

class _ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] --> ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('[API] body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final body = '${response.data}';
    final trimmedBody = body.length > 500
        ? '${body.substring(0, 500)}...'
        : body;
    debugPrint(
      '[API] <-- ${response.requestOptions.method} '
      '${response.requestOptions.uri} ${response.statusCode}',
    );
    if (trimmedBody.isNotEmpty && trimmedBody != 'null') {
      debugPrint('[API] response: $trimmedBody');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[API] !! ${err.requestOptions.method} ${err.requestOptions.uri}: $err',
    );
    handler.next(err);
  }
}
