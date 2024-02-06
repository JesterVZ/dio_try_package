# TryDio
TryDio is a Dart package designed to streamline network operations in Flutter applications. It provides a robust framework for making HTTP requests while gracefully handling exceptions and errors that may occur during network communication. By abstracting the complexities of direct HTTP calls and error handling into a simple, unified API, FlutterSafeNet enables developers to focus on building their application's core functionalities without worrying about the underlying network layer details.

Installation
To use TryDio in your Flutter project, add it as a dependency in your pubspec.yaml file:

``` dart
yaml
dependencies:
  try_dio: ^0.0.5
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
final result = await safeCall<String>(() async {
  throw DioException(
    requestOptions: RequestOptions(path: 'https://example.com'),
    // Specify the type of exception
    type: DioExceptionType.other,
    error: "Connection error",
  );
});
if (result.isSuccess()) {
  // Successful execution
} else {
  final error = result.error();
  switch(error){
    HttpError error => print(error.statusCode),
    ConnectionError 
  }
  if (error is HttpError) {
    // Handle HTTP errors
    print(error.statusCode);
  } else if (error is ConnectionError) {
    // Handle connection errors
    print(error.code);
  } else {
    // Handle other errors
    print(error.code);
  }
}
```
Notes
Make sure you handle asynchronous operations properly using async and await.
Use type checking with is to handle specific errors.
