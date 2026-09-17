import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

/// Mudança de dados avisada pelo servidor via WebSocket. `empresaId` só vem
/// preenchido em mudanças escopadas a uma empresa -- mudanças globais (ex:
/// referência/tabela de preço compartilhada entre empresas) chegam sem ele.
/// O client não precisa filtrar por `empresaId`: o servidor só entrega no
/// socket os eventos relevantes pra empresa da sessão (via room), então tudo
/// que chega aqui já diz respeito ao usuário atual.
class SyncMudancaEvent {
  final String modulo;
  final int? empresaId;

  const SyncMudancaEvent({required this.modulo, this.empresaId});
}

/// Wrapper fino sobre `socket_io_client` -- evita dependência direta de
/// package de terceiro fora do core (ver convenção do projeto).
///
/// Conecta no namespace `/sync` da mesma origem da API REST, autenticando
/// com o JWT da sessão. Reconexão automática fica a cargo do socket.io
/// (`enableReconnection`), sem lógica manual de retry aqui.
class SyncWebSocketService {
  socket_io.Socket? _socket;
  String? _tokenConectado;

  final _mudancasController = StreamController<SyncMudancaEvent>.broadcast();
  final _conectadoController = StreamController<bool>.broadcast();

  Stream<SyncMudancaEvent> get mudancas => _mudancasController.stream;
  Stream<bool> get conectado => _conectadoController.stream;

  /// Conecta (ou reusa a conexão já aberta com o mesmo [token]). Chamar de
  /// novo com o mesmo token é no-op -- seguro de chamar em todo ponto de
  /// entrada de sessão sem precisar rastrear se já conectou.
  void connect({required String token, required String baseUrl}) {
    if (_socket != null && _tokenConectado == token) {
      return;
    }
    disconnect();
    _tokenConectado = token;

    final origem = Uri.parse(baseUrl);
    final socketUrl = '${origem.scheme}://${origem.authority}/sync';

    _socket =
        socket_io.io(
            socketUrl,
            socket_io.OptionBuilder()
                .setTransports(['websocket'])
                .setAuth({'token': token})
                .enableReconnection()
                .build(),
          )
          ..onConnect((_) => _conectadoController.add(true))
          ..onDisconnect((_) => _conectadoController.add(false))
          ..on('sync:mudanca', _onMudanca)
          ..connect();
  }

  void _onMudanca(dynamic data) {
    if (data is! Map) return;
    _mudancasController.add(
      SyncMudancaEvent(
        modulo: data['modulo'] as String,
        empresaId: data['empresaId'] as int?,
      ),
    );
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _tokenConectado = null;
  }
}
