import 'package:core/remote_data_sourcers.dart';
import 'package:notificacoes/domain/notificacao.dart';
import 'package:notificacoes/domain/notificacoes_gateway.dart';

class NotificacoesRemoteDataSource extends RemoteDataSourceBase
    implements NotificacoesGateway {
  NotificacoesRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/notificacoes{path}';

  @override
  Future<List<Notificacao>> listarNaoLidas({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      pathParameters: {'path': ''},
      queryParameters: {'lida': 'false', 'page': '$page', 'limit': '$limit'},
    );
    return parseLista(response.body);
  }

  /// Tolerante: lista simples ou objeto com `data`/`items`.
  static List<Notificacao> parseLista(dynamic body) {
    final lista = body is List
        ? body
        : (body is Map ? (body['data'] ?? body['items']) : null) as List? ?? [];
    return [
      for (final j in lista) Notificacao.fromJson(j as Map<String, dynamic>),
    ];
  }

  @override
  Future<int> contarNaoLidas() async {
    final response = await get(
      pathParameters: {'path': '/nao-lidas/contagem'},
    );
    return ((response.body as Map)['total'] as num).toInt();
  }

  @override
  Future<void> marcarLida(int id) async {
    await patch(pathParameters: {'path': '/$id/lida'}, body: <String, dynamic>{});
  }

  @override
  Future<void> marcarTodasLidas() async {
    await patch(pathParameters: {'path': '/lidas'}, body: <String, dynamic>{});
  }
}
