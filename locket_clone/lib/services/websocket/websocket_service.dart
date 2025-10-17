import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef StompMessageHandler = void Function(Map<String, dynamic> json);

class WebSocketService {
  WebSocketService._();
  static final WebSocketService I = WebSocketService._();

  StompClient? _client;

  bool get isConnected => _client?.connected == true;

  void connect({
    required String url, // ws://<host>:<port>/ws
    void Function()? onConnected,
    void Function(Object, StackTrace)? onError,
  }) {
    // Nếu đã kết nối rồi thì bỏ qua
    if (isConnected) {
      onConnected?.call();
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: url,
        connectionTimeout: const Duration(seconds: 10),
        onConnect: (frame) => onConnected?.call(),
        onStompError: (frame) {
          onError?.call(
            Exception('STOMP error: ${frame.body}'),
            StackTrace.current,
          );
        },
        onWebSocketError: (err) {
          onError?.call(err, StackTrace.current);
        },
        onDisconnect: (frame) {},
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
        reconnectDelay: const Duration(milliseconds: 1500),
      ),
    );

    _client!.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  /// Đăng ký topic
  StompUnsubscribe? subscribeTopic(
    String destination,
    StompMessageHandler onMessage,
  ) {
    if (!isConnected) return null;
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
    if (!isConnected) return;
    _client!.send(
      destination: destination,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
  }
}
