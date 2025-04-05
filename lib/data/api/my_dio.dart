import "package:dio/dio.dart";
import "package:tripmate/src/data/api/interceptor/auth_interceptor.dart";
import "package:tripmate/src/data/api/interceptor/exception_interceptor.dart";
import "package:tripmate/src/data/data_source/hive.dart";

enum DioType {
  authToken,
  authTokenWoLogin,
  validationToken,
  none,
}

Future<Dio> tripmateDio(context, DioType dioType) async {
  TripMateHive tripMateHive = TripMateHive();
  var dio = Dio();
  dio.options.validateStatus = (status) => status! < 500;
  dio.interceptors.clear();
  dio.interceptors.add(exceptionInterceptor(dio, context));

  switch (dioType) {
    case DioType.authToken:
      dio.interceptors.add(authInterceptor(dio, context));

    case DioType.authTokenWoLogin:
      // 로그인이 필요한 경우 로그인 팝업을 띄우지 않고 무시합니다.
      dio.interceptors.add(authInterceptor(dio, context, ignoreLogin: true));

    case DioType.validationToken:
      // 비 로그인 상태에서 이메일 인증, 휴대전화 번호 인증 등에 사용하는 토큰.
      String validToken = tripMateHive.getValidationToken();
      dio.options.headers["Authorization"] = "Bearer $validToken";

    case DioType.none:
      break;
  }

  return dio;
}
