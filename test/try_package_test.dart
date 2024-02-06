import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:try_dio/try_package.dart';

void main() {
  group('safeCall tests', () {
    test('Returns TrySuccess on successful action', () async {
      final result = await safeCall(() async => 'Success');
      expect(result.isSuccess(), isTrue);
      expect(result.result(), 'Success');
    });

    test('Returns TryError of type ParsingError on FormatException', () async {
      final result = await safeCall<String>(() async => throw const FormatException('Invalid format'));
      expect(result.isSuccess(), isFalse);
      expect(result.error(), isA<ParsingError>());
    });

    test('Returns TryError of type HttpError on DioException with badResponse', () async {
      final response = Response(
        requestOptions: RequestOptions(path: 'test'),
        statusCode: 404,
        statusMessage: 'Not Found',
      );
      final dioError = DioException(
        error: 'Error',
        response: response,
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: 'test'),
      );
      
      final result = await safeCall<String>(() async => throw dioError);
      expect(result.isSuccess(), isFalse);
      expect(result.error(), isA<HttpError>());
      expect((result.error() as HttpError).statusCode, 404);
    });

    // Добавьте дополнительные тесты для остальных типов ошибок...
  });
}