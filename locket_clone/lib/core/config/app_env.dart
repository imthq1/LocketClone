import 'package:flutter/foundation.dart';

class AppEnv {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    } else {
      return 'http://10.0.2.2:8080/api/v1';
    }
  }

  static const String authHeader = 'Authorization';
}
