import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

/// Client cho Android/iOS (IO). Không hỗ trợ web.
class HttpClientPlatformImpl {
  http.Client get client => IOClient();
}
