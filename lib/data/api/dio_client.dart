import "dart:convert";

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:logger/logger.dart";
import "package:tripmate/src/data/api/my_dio.dart";

enum ApiResponse {
  result,
  statusCode,
  data,
  statusMessage,
}

enum ApiResult {
  success,
  error,
  forbidden,
  notFound,
  notAcceptable,
  conflict,
  unprocessibleEntity,
  internalServerError,
}

enum ContentType {
  json,
  form,
  plainText,
  formData,
}

extension ContentTypeExtension on ContentType {
  String get convertedText {
    switch (this) {
      case ContentType.json:
        return "application/json";
      case ContentType.form:
        return "application/x-www-form-urlencoded";
      case ContentType.formData:
        return "multipart/form-data";
      default:
        return "text/plain";
    }
  }
}

class DioClient {
  static String baseUrl = dotenv.get("TRIPMATE_API_BASE_URL");
  final Logger _logger = Logger();

  /// get method
  Future<Map<ApiResponse, dynamic>> getRequest(
    BuildContext context,
    String url, {
    DioType dioType = DioType.authToken,
    ContentType contentType = ContentType.json,
  }) async {
    Dio dio = await tripmateDio(context, dioType);
    Response response = await dio.get("$baseUrl$url");
    return buildResult(response);
  }

  /// post method
  Future<Map<ApiResponse, dynamic>> postRequest(
    BuildContext context,
    String url,
    Object? data, {
    DioType dioType = DioType.authToken,
    ContentType contentType = ContentType.json,
  }) async {
    Dio dio = await tripmateDio(context, dioType);
    Response response = await dio.post("$baseUrl$url", data: contentType == ContentType.json ? jsonEncode(data) : data);
    return buildResult(response);
  }

  /// put method
  Future<Map<ApiResponse, dynamic>> putRequest(
    BuildContext context,
    String url,
    Object? data, {
    DioType dioType = DioType.authToken,
    ContentType contentType = ContentType.json,
  }) async {
    Dio dio = await tripmateDio(context, dioType);
    Response response = await dio.put("$baseUrl$url", data: contentType == ContentType.json ? jsonEncode(data) : data);
    return buildResult(response);
  }

  /// delete method
  Future<Map<ApiResponse, dynamic>> deleteRequest(
    BuildContext context,
    String url, {
    Object? data,
    DioType dioType = DioType.authToken,
    ContentType contentType = ContentType.json,
  }) async {
    Dio dio = await tripmateDio(context, dioType);
    Response response =
        await dio.delete("$baseUrl$url", data: contentType == ContentType.json ? jsonEncode(data) : data);
    return buildResult(response);
  }

  ApiResult convertApiResult(int? statusCode) {
    switch (statusCode) {
      case 200:
      case 201:
      case 202:
        return ApiResult.success;
      case 403:
        return ApiResult.forbidden;
      case 404:
        return ApiResult.notFound;
      case 406:
        return ApiResult.notAcceptable;
      case 409:
        return ApiResult.conflict;
      case 422:
        return ApiResult.unprocessibleEntity;
      case 500:
        return ApiResult.internalServerError;
      default:
        return ApiResult.error;
    }
  }

  Map<ApiResponse, dynamic> buildResult(response) {
    _logger.d("${response.realUri} + statusCode: ${response.statusCode} + responseBody: ${response.data}");

    return {
      ApiResponse.statusCode: response.statusCode,
      ApiResponse.result: convertApiResult(response.statusCode),
      ApiResponse.data: response.data,
      ApiResponse.statusMessage: response.statusMessage,
    };
  }
}

class InternalServerException implements Exception {
  InternalServerException(this.error);
  String error;
}
