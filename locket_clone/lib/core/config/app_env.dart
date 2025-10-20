import 'package:flutter/foundation.dart';

class AppEnv {
  static String get baseUrl {
    if (kIsWeb) {
      // Khi chạy Flutter Web
      return 'http://localhost:8080/api/v1';
    } else {
      // Khi chạy trên Android emulator
      return 'http://10.0.2.2:8080/api/v1';
    }
  }

  static const String authHeader = 'Authorization';
}
