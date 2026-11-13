/// Competition — the socket.io client for Learn Together.
///
/// Mirrors `yi-chinese-manage/lib/competition/socket.ts` and the handlers in
/// `Learning/web_app/service/competition_socket.py`. The web carries a
/// Flask-Login session cookie on the handshake; the mobile client has no cookie,
/// so it passes its bearer token via the socket.io `auth` option — the backend's
/// `connect` handler verifies it and binds `current_user` for every event
/// (see P11-backend). Created disconnected; the owning controller calls
/// [connect] / [dispose].
///
/// Websocket-only: the Dart engine.io client opens the polling URL as a websocket
/// ("was not upgraded to websocket"), so polling can't be used. Flask-SocketIO in
/// threading mode needs `simple-websocket` for this (see requirements.txt).
library;

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef JsonHandler = void Function(Map<String, dynamic> data);

class CompetitionSocket {
  CompetitionSocket({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  io.Socket? _socket;

  void connect({
    required void Function() onConnect,
    required void Function() onConnectError,
    required Map<String, JsonHandler> handlers,
  }) {
    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) => onConnect());
    socket.onConnectError((error) {
      debugPrint('[CompetitionSocket] connect_error @ $baseUrl: $error');
      onConnectError();
    });

    handlers.forEach((event, handler) {
      socket.on(event, (data) {
        handler(data is Map ? data.cast<String, dynamic>() : const {});
      });
    });

    socket.connect();
  }

  void emit(String event, [Map<String, dynamic>? payload]) {
    final socket = _socket;
    if (socket == null) return;
    if (payload == null) {
      socket.emit(event);
    } else {
      socket.emit(event, payload);
    }
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
