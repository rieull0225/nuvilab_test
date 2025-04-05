import "dart:async";
import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/material.dart";

// 네트워크 bottom modal
class MySocketException extends SocketException {
  MySocketException(String message, this.context) : super(message);
  final BuildContext context;

  //TODO ALERT MESSAGE
}

// 타임아웃 dialog
class MyTimeoutException extends TimeoutException {
  MyTimeoutException(String? message, this.dio) : super(message);
  final Dio dio;

  //TODO ALERT MESSAGE
}

// 모든 에러 && 500 에러
class MyException implements Exception {
  //TODO ALERT MESSAGE
}
