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

/// Andamento de uma importação (evento `importacao:progresso`). `tipo` e
/// `situacao` chegam em minúsculas. O detalhe das rejeições não vem no evento:
/// o app consulta `GET /v1/importacao/:id` quando a importação termina.
class ImportacaoProgressoEvent {
  final int id;
  final String tipo;
  final String situacao;
  final int totalRegistros;
  final int processados;
  final int importados;
  final int rejeitados;
  final String? erro;

  const ImportacaoProgressoEvent({
    required this.id,
    required this.tipo,
    required this.situacao,
    this.totalRegistros = 0,
    this.processados = 0,
    this.importados = 0,
    this.rejeitados = 0,
    this.erro,
  });

  factory ImportacaoProgressoEvent.fromJson(Map<dynamic, dynamic> json) {
    int numero(String chave) => (json[chave] as num?)?.toInt() ?? 0;
    return ImportacaoProgressoEvent(
      id: numero('id'),
      tipo: (json['tipo'] as String? ?? '').toLowerCase(),
      situacao: (json['situacao'] as String? ?? '').toLowerCase(),
      totalRegistros: numero('totalRegistros'),
      processados: numero('processados'),
      importados: numero('importados'),
      rejeitados: numero('rejeitados'),
      erro: json['erro'] as String?,
    );
  }
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
  final _importacoesController =
      StreamController<ImportacaoProgressoEvent>.broadcast();

  Stream<SyncMudancaEvent> get mudancas => _mudancasController.stream;
  Stream<ImportacaoProgressoEvent> get importacoes =>
      _importacoesController.stream;
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

    _socket = socket_io.io(
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
      ..on('importacao:progresso', _onImportacao)
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

  void _onImportacao(dynamic data) {
    if (data is! Map) return;
    _importacoesController.add(ImportacaoProgressoEvent.fromJson(data));
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _tokenConectado = null;
  }
}
