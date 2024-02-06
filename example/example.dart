import 'package:dio/dio.dart';
import 'package:try_dio/try_package.dart';
void main() async{
  final result = await safeCall<String>(() async {
  throw DioException(
    requestOptions: RequestOptions(path: 'https://example.com'),
    // Specify the type of exception
    type: DioExceptionType.badCertificate,
    error: "Connection error",
  );
});
if (result.isSuccess()) {
  // Successful execution
} else {
  final error = result.error();
  switch(error){
    case HttpError():
      print(error.statusCode);
    case ConnectionError():
      print(error.code);
    case DtoError():
    case ParsingError():
    case UnknownError():
    case SocketError():
      print(error.code);
  }
}
}
