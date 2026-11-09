import 'package:notificacoes/domain/notificacao.dart';
import 'package:notificacoes/domain/notificacoes_gateway.dart';

class ListarNotificacoesNaoLidas {
  final NotificacoesGateway gateway;
  ListarNotificacoesNaoLidas(this.gateway);

  Future<List<Notificacao>> call({int page = 1, int limit = 20}) =>
      gateway.listarNaoLidas(page: page, limit: limit);
}

class ContarNotificacoesNaoLidas {
  final NotificacoesGateway gateway;
  ContarNotificacoesNaoLidas(this.gateway);

  Future<int> call() => gateway.contarNaoLidas();
}

class MarcarNotificacaoLida {
  final NotificacoesGateway gateway;
  MarcarNotificacaoLida(this.gateway);

  Future<void> call(int id) => gateway.marcarLida(id);
}

class MarcarTodasNotificacoesLidas {
  final NotificacoesGateway gateway;
  MarcarTodasNotificacoesLidas(this.gateway);

  Future<void> call() => gateway.marcarTodasLidas();
}
