import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:logger/logger.dart";

/// Http 요청에서 5XX 에러 발생하는 경우를 처리합니다.
InterceptorsWrapper exceptionInterceptor(Dio dio, BuildContext context) {
  Logger logger = Logger();

  Future<Response<dynamic>> cloneDioError(Dio dio, DioException error) {
    return dio.request(
      error.requestOptions.path,
      options: Options(method: error.requestOptions.method, headers: error.requestOptions.headers),
      data: error.requestOptions.data,
      queryParameters: error.requestOptions.queryParameters,
    );
  }

  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      logger.d("${options.uri} + headers: ${options.headers} + requestBody: ${options.data}");
      return handler.next(options);
    },
    onResponse: (response, handler) async {
      logger.d("${response.realUri} + statusCode: ${response.statusCode} + responseBody: ${response.data}");
      return handler.next(response);
    },
    onError: (error, handler) async {
      logger.e("${error.type} + ${error.response?.realUri} + ${error.response?.statusCode} + ${error.response?.data}");

      if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
        //TODO ALERT MESSAGE 제작 이후 주석제거
        // await MyTimeoutException.showAlert(error.message ?? '', context);
        var clonedRequest = await cloneDioError(dio, error);
        return handler.resolve(clonedRequest);
      } else if (error.type == DioExceptionType.badResponse) {
        if (error.message!.contains("SocketException")) {
          // await MySocketException.showAlert(error.message ?? '', context);
          var clonedRequest = await cloneDioError(dio, error);
          return handler.resolve(clonedRequest);
        } else {
          return handler.next(error);
        }
      } else {
        if (error.response?.statusCode != 500) {
          // MyException.showAlert(context);
          return handler.next(error);
        }

        if (error.response?.data is List && error.response?.data[0].containsKey("message")) {
          // MyException.showAlert(context, errorMsg: error.response?.data[0]['message']);
          return handler.next(error);
        }

        // if (!error.response?.data is List && error.response?.data.containsKey('message')) {
        //   MyException.showAlert(context, errorMsg: error.response?.data['message']);
        //   return handler.next(error);
        // }

        // MyException.showAlert(context);
        return handler.next(error);
      }
    },
  );
}
