import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef StompMessageHandler = void Function(Map<String, dynamic> json);

class WebSocketService extends ChangeNotifier {
  WebSocketService._();
  static final WebSocketService I = WebSocketService._();

  StompClient? _client;
  String? _jwt; // Lưu token

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void _setConnected(bool v) {
    if (_isConnected == v) return; // Tránh thông báo nếu không đổi
    _isConnected = v;
    notifyListeners(); // Thông báo cho UI
  }

  void connect({
    required String url,
    required String jwt, // Yêu cầu token
    void Function(Object, StackTrace)? onError,
  }) {
    // Nếu đang kết nối với cùng token thì bỏ qua
    if (isConnected && _jwt == jwt && _client != null) {
      return;
    }

    // Nếu client đang hoạt động, ngắt nó trước khi tạo kết nối mới
    if (_client?.connected == true || _client?.isActive == true) {
      _client?.deactivate();
    }

    _jwt = jwt;

    _client = StompClient(
      config: StompConfig(
        url: url,
        connectionTimeout: const Duration(seconds: 10),
        onConnect: (frame) {
          _setConnected(true);
        },
        onStompError: (frame) {
          _setConnected(false);
          onError?.call(
            Exception('STOMP error: ${frame.body}'),
            StackTrace.current,
          );
        },
        onWebSocketError: (err) {
          _setConnected(false);
          onError?.call(err ?? 'Unknown WS Error', StackTrace.current);
        },
        onDisconnect: (frame) {
          _setConnected(false);
        },
        // Thêm headers xác thực vào đây
        stompConnectHeaders: {'Authorization': 'Bearer $_jwt'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $_jwt'},
        reconnectDelay: const Duration(milliseconds: 1500),
        // Tắt heart-beat của STOMP nếu server không hỗ trợ
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _jwt = null;
    _setConnected(false);
  }

  /// Đăng ký topic
  StompUnsubscribe? subscribeTopic(
    String destination,
    StompMessageHandler onMessage,
  ) {
    if (!isConnected || _client == null) return null;
    return _client!.subscribe(
      destination: destination,
      callback: (StompFrame f) {
        if (f.body == null) return;
        try {
          final json = jsonDecode(f.body!) as Map<String, dynamic>;
          onMessage(json);
        } catch (_) {}
      },
    );
  }

  /// Gửi tin nhắn tới server
  void send(String destination, Map<String, dynamic> body) {
    if (!isConnected || _client == null) return;
    _client!.send(
      destination: destination,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
  }
}