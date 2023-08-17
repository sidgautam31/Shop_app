import 'package:flutter/foundation.dart';

class HTTPException implements Exception {
  final String message;
  HTTPException(this.message);

  @override
  String toString() {
    return message;
    //return super.toString();  // It returns instance of HTTP Exception
  }
}