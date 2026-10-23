import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_descontos_fidelidade_remote_data_source.dart';
import 'package:empresas/domain/entities/desconto_fidelidade.dart';

class DescontosFidelidadeRemoteDataSource extends RemoteDataSourceBase
    implements IDescontosFidelidadeRemoteDataSource {
  DescontosFidelidadeRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path =>
      '/v1/empresas/{empresaId}/configuracoes/fidelidade/descontos{id}';

  @override
  Future<List<DescontoFidelidade>> listar(int empresaId) async {
    final response = await get(pathParameters: {'empresaId': empresaId});
    return (response.body as List).map((e) {
      final j = e as Map<String, dynamic>;
      return DescontoFidelidade(
        id: (j['id'] as num).toInt(),
        pontos: (j['pontos'] as num).toInt(),
        tipo: j['tipo'] as String,
        valor: double.parse(j['valor'].toString()),
        cumulativo: j['cumulativo'] as bool? ?? false,
        ativo: j['ativo'] as bool? ?? true,
      );
    }).toList();
  }

  @override
  Future<void> salvar(int empresaId, DescontoFidelidade d) async {
    final body = {
      'pontos': d.pontos,
      'tipo': d.tipo,
      'valor': d.valor,
      'cumulativo': d.cumulativo,
      'ativo': d.ativo,
    };
    if (d.id == null) {
      await post(pathParameters: {'empresaId': empresaId}, body: body);
    } else {
      await put(pathParameters: {'empresaId': empresaId, 'id': '/${d.id}'}, body: body);
    }
  }

  @override
  Future<void> excluir(int empresaId, int id) =>
      delete(pathParameters: {'empresaId': empresaId, 'id': '/$id'});
}
