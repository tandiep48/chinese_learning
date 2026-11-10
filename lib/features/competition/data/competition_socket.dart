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
/// Transports are left at polling + websocket (not websocket-only): Flask-SocketIO
/// runs in threading mode, where the websocket upgrade needs `simple-websocket`
/// installed — leaving polling in the list keeps the connection working without it.
library;

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
          .setTransports(['polling', 'websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) => onConnect());
    socket.onConnectError((_) => onConnectError());

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
