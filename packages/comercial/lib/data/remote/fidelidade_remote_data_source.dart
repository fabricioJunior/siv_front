import 'package:comercial/domain/data/remote/i_fidelidade_remote_data_source.dart';
import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';
import 'package:core/remote_data_sourcers.dart';

class FidelidadeRemoteDataSource extends RemoteDataSourceBase
    implements IFidelidadeRemoteDataSource {
  FidelidadeRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}/{recurso}';

  @override
  Future<bool> verificarElegibilidade({required int pessoaId}) async {
    final response = await get(
      pathParameters: {'pessoaId': pessoaId, 'recurso': 'elegivel-fidelidade'},
    );

    final body = response.body;
    if (body is Map<String, dynamic>) {
      return body['elegivel'] == true;
    }

    return false;
  }

  @override
  Future<OpcoesResgatePontos> recuperarOpcoesResgate({
    required int pessoaId,
  }) async {
    final response = await get(
      pathParameters: {
        'pessoaId': pessoaId,
        'recurso': 'pontos/resgate-opcoes',
      },
    );
    final j = response.body as Map<String, dynamic>;
    return OpcoesResgatePontos(
      saldo: (j['saldo'] as num? ?? 0).toInt(),
      valorPorPonto: j['valorPorPonto'] == null
          ? null
          : double.parse(j['valorPorPonto'].toString()),
      cumulativoValorPorPonto: j['cumulativoValorPorPonto'] == true,
      faixas: [
        for (final f in (j['faixas'] as List? ?? const []))
          FaixaResgate(
            id: (f['id'] as num).toInt(),
            pontos: (f['pontos'] as num).toInt(),
            tipo: f['tipo'] as String,
            valor: double.parse(f['valor'].toString()),
            cumulativo: f['cumulativo'] == true,
            disponivel: f['disponivel'] == true,
          ),
      ],
    );
  }
}
