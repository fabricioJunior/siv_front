import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/caixa_dto.dart';
import 'package:financeiro/domain/data/remote/i_caixa_remote_data_source.dart';
import 'package:financeiro/domain/models/caixa.dart';

class CaixaRemoteDataSource extends RemoteDataSourceBase
    implements ICaixaRemoteDataSource {
  CaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{operacao}';

  @override
  Future<Caixa> abrirCaixa({
    required int idEmpresa,
    required int terminalId,
  }) async {
    final response = await post(
      pathParameters: {'operacao': 'abrir'},
      body: {
        'empresaId': idEmpresa,
        'terminalId': terminalId,
      },
    );

    return CaixaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Caixa?> recuperarCaixaAberto({
    required int idEmpresa,
    required int terminalId,
  }) async {
    var queryParamenters = {
      'empresaId': idEmpresa.toString(),
      'terminalId': terminalId.toString(),
    };

    var pathParameters = {'operacao': 'aberto'};

    final response = await get(
        queryParameters: queryParamenters, pathParameters: pathParameters);
    if (response.body == null || response.body.toString().trim().isEmpty) {
      return null;
    }
    return CaixaDto.fromJson(response.body as Map<String, dynamic>);
  }
}
