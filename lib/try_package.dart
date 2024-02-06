import 'dart:io';
import 'package:dio/dio.dart';

sealed class AppError implements Exception{
  AppError({this.stackTrace, this.cause});
  final StackTrace? stackTrace;
  final Exception? cause;

  String get code;
}

class HttpError extends AppError{
  final int statusCode;
  final String? statusMessage;
  final String? bodyJson;
  final String url;


  HttpError({
    required this.statusCode,
    required this.url,
    this.statusMessage,
    this.bodyJson,
    super.stackTrace,
    super.cause
  });

  
  @override
  String get code => "HttpError[$statusCode] - $url";
}

class ConnectionError extends AppError{

  ConnectionError({super.stackTrace, super.cause});

  @override
  String get code => "ConnectionError";
}
class DtoError extends AppError{
  final Error? error;
  DtoError({ super.stackTrace, super.cause, this.error});

  @override
  String get code => "DtoError Error";
}
class ParsingError extends AppError {

  ParsingError({ super.stackTrace, super.cause});

  @override
  String get code => "ParsingError Error";
}
class UnknownError extends AppError{
  UnknownError({ super.stackTrace, super.cause, this.error});
  final Object? error;

  @override
  String get code => "UnknownError Error";
}

class SocketError extends AppError{
  SocketError({super.stackTrace, super.cause});

  @override
  String get code => "SocketError Error";
}


typedef FutureTry<T> = Future<Try<T>>;


sealed class Try<T>{

  Try._();

  bool isSuccess();
  T result();
  AppError error();

  factory Try.emptySuccess() = EmptySuccess;
  factory Try.success(T data) = TrySuccess;
  factory Try.error(AppError error) = TryError;
}

class TrySuccess<T> extends Try<T>{
  final T data;

  TrySuccess(this.data):super._();

  @override
  bool isSuccess(){
    return true;
  }

  @override
  T result(){
    return data;
  }

  @override
  AppError error(){
    throw Exception('Object is not Error! Check with isError() before use');
  }

}

class TryError<T> extends Try<T>{
  final AppError _error;

  TryError(this._error):super._();

  @override
  bool isSuccess(){
    return false;
  }

  @override
  T result(){
    throw Exception('Object is not Success! Check with isSuccess() before use');
  }

  @override
  AppError error(){
    return _error;
  }
}

class EmptySuccess<T> extends Try<T> {
  EmptySuccess() : super._();

  @override
  bool isSuccess() {
    return true;
  }

  @override
  T result() {
    throw Exception('EmptySuccess does not contain result data');
  }

  @override
  AppError error() {
    throw Exception('EmptySuccess does not contain an error');
  }
}

/// Обработка http клиента
typedef TryCall<T> = Future<T> Function();

FutureTry<T> safeCall<T>(TryCall<T> action) async {
  try{
    return Try.success(await action.call());
  }on FormatException catch(e, stack){
    ///написать нужно те, которые вылетают при ошибке парсинга
    // Возможно ошибка при парсинге json
    return Try.error(
        ParsingError(
            stackTrace: stack
        )
    );
  }on DioException catch (e, stack){

    AppError getBadResponse(){
      if (e.response != null &&
          e.response?.statusCode != null &&
          e.response?.statusMessage != null) {
        return HttpError(
            url: e.requestOptions.path,
            statusCode: e.response?.statusCode ?? 0,
            statusMessage: e.response?.statusMessage,
            stackTrace: stack,
        );
      } else {
        return UnknownError(
            stackTrace: stack
        );
      }
    }

    return Try.error(
        switch (e.type){
          DioExceptionType.connectionTimeout => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.sendTimeout => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.receiveTimeout => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.badCertificate => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.badResponse => getBadResponse(),
          DioExceptionType.cancel => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.connectionError => ConnectionError(
              cause: e,
              stackTrace: stack
          ),
          DioExceptionType.unknown => UnknownError(
              cause: e,
              stackTrace: stack
          ),
        });
  } on SocketException catch(e, stack){
    return Try.error(SocketError (stackTrace: stack, cause: e));
  } on IOException catch(e, stack){
    // Скорее всего траблы с коннектом
    return Try.error(
        ConnectionError(
            stackTrace: stack,
            cause: e
        )
    );
  } on TypeError catch(e, stack){
    /// DTO error
    return Try.error(
        DtoError(
            stackTrace: stack,
            error: e
        )
    );
  } catch (e, stack){
    // Неперехваченная выше ошибка
    return Try.error(
        UnknownError(
            error: e,
            stackTrace: stack,
        )
    );
  }
}