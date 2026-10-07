import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/utils/failure.dart';

import 'helpers.dart';

void main() {
  FailureType typeOf(DioException e) => Failure.from(e).type;

  test('mapping des erreurs HTTP vers FailureType', () {
    expect(typeOf(dioError(DioExceptionType.connectionError)), FailureType.network);
    expect(typeOf(dioError(DioExceptionType.badResponse, status: 401)), FailureType.unauthorized);
    expect(typeOf(dioError(DioExceptionType.badResponse, status: 403)), FailureType.forbidden);
    expect(typeOf(dioError(DioExceptionType.badResponse, status: 404)), FailureType.notFound);
    expect(typeOf(dioError(DioExceptionType.badResponse, status: 400)), FailureType.validation);
    expect(typeOf(dioError(DioExceptionType.badResponse, status: 503)), FailureType.server);
  });
}
