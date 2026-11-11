import 'package:notificacoes/domain/notificacao.dart';

/// Porta de acesso às notificações (REST `/v1/notificacoes`).
abstract class NotificacoesGateway {
  Future<List<Notificacao>> listarNaoLidas({int page = 1, int limit = 20});
  Future<int> contarNaoLidas();
  Future<void> marcarLida(int id);
  Future<void> marcarTodasLidas();
}
