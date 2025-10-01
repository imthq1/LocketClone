import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:locket_clone/core/security/token_store.dart';
import 'package:locket_clone/core/network/http_client.dart'; // Android-only client bạn đã làm
import 'package:locket_clone/core/models/friend_models.dart';

class FriendRepository {
  // Android emulator → 10.0.2.2; nếu bạn thật sự dùng IP LAN thì truyền qua --dart-define hoặc đổi defaultValue
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );
  static const int _port = int.fromEnvironment('API_PORT', defaultValue: 8080);

  final http.Client _http = HttpClientPlatformImpl().client;
  final TokenStore _token = TokenStore();

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.http('$_host:$_port', path, q);

  /// GET /api/v1/listRequestByAddressee
  Future<List<FriendRequestReceived>> listReceived() async {
    final token = await _token.getAccessToken();
    final url = _u('/api/v1/listRequestByAddressee');

    final res = await _http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('[Friends][received] ${res.statusCode} ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('listReceived failed: ${res.statusCode}');
    }
    final raw = jsonDecode(res.body);

    // JSON: { statusCode, message, data: [ {...}, ... ] }
    final list = (raw is Map && raw['data'] is List)
        ? raw['data'] as List
        : <dynamic>[];
    return list
        .cast<Map>()
        .map((e) => FriendRequestReceived.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// GET /api/v1/listFriendSend?page=&size=
  Future<PageResp<FriendRequestSent>> listSent({
    int page = 0,
    int size = 20,
  }) async {
    final token = await _token.getAccessToken();
    final url = _u('/api/v1/listFriendSend', {
      'page': '$page',
      'size': '$size',
    });

    final res = await _http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('[Friends][sent] ${res.statusCode} ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('listSent failed: ${res.statusCode}');
    }
    final raw = jsonDecode(res.body);

    // JSON: { statusCode, message, data: { content: [...], page: {...} } }
    final data = (raw is Map && raw['data'] is Map)
        ? (raw['data'] as Map).cast<String, dynamic>()
        : <String, dynamic>{
            'content': <dynamic>[],
            'page': {
              'size': 0,
              'number': 0,
              'totalElements': 0,
              'totalPages': 0,
            },
          };

    return PageResp.fromJson<FriendRequestSent>(
      data,
      (j) => FriendRequestSent.fromJson(j),
    );
  }
}
