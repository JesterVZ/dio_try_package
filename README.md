# TryDio
TryDio is a Dart package designed to streamline network operations in Flutter applications. It provides a robust framework for making HTTP requests while gracefully handling exceptions and errors that may occur during network communication. By abstracting the complexities of direct HTTP calls and error handling into a simple, unified API, TryDio enables developers to focus on building their application's core functionalities without worrying about the underlying network layer details.

Installation
To use TryDio in your Flutter project, add it as a dependency in your pubspec.yaml file:

``` dart
yaml
dependencies:
  try_dio: ^0.0.6
```
Usage
Basic Example
This example demonstrates how to use the safeCall function to perform a network request and handle the response or error in a safe, predictable manner.

```dart
import 'package:fluttersafenet/fluttersafenet.dart'; // Import necessary modules

void main() async {
  final result = await safeCall<String>(() async {
    // Your code to perform an HTTP request, e.g., using Dio
    return "Successful response from the server";
  });

  if (result.isSuccess()) {
    print(result.result()); // Handle the successful response
  } else {
    print(result.error().code); // Handle the error
  }
}
```
Handling Exceptions
Here's how you can handle different types of exceptions returned by the safeCall function:

```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApi api;
  AuthRemoteDataSourceImpl({required this.api});

  @override
  FutureTry<GetSmsCodeResponse> getSmsCode(GetSmsCodeRequest request) {
    return safeCall(() => api.getSmsCode(request));
  }

  @override
  FutureTry<void> logOut(String token) {
    return safeCall(() => api.logOut(token));
  }

  @override
  FutureTry<void> setSecureCode(SetSecureCodeRequest request) {
    return safeCall(() => api.setSecureCode(request));
  }

  @override
  FutureTry<ValidateTokenResponse> validateToken(ValidateTokenRequest request) {
    return safeCall(() => api.validateToken(request));
  }

  @override
  FutureTry<VerifySecureCodeResponse> verifySecureCode(VerifySecureCodeRequest request) {
    return safeCall(() => api.verifySecureCode(request));
  }

  @override
  FutureTry<VerifySmsCodeResponse> verifySmsCode(VerifySmsCodeRequest request) {
    return safeCall(() => api.verifySmsCode(request));
  }

}
```
Notes
Make sure you handle asynchronous operations properly using async and await.
Use type checking with is to handle specific errors.
