import 'package:core/remote_data_sourcers.dart';
import 'package:promocoes/domain/data/remote/i_elegibilidade_remote_data_source.dart';
import 'package:promocoes/domain/models/elegibilidade.dart';

class ElegibilidadeRemoteDataSource extends RemoteDataSourceBase
    implements IElegibilidadeRemoteDataSource {
  ElegibilidadeRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/desconto-elegibilidade/apurar';

  @override
  Future<ResultadoElegibilidade> apurar({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  }) async {
    final response = await post(
      body: {
        if (clienteId != null) 'clienteId': clienteId,
        'itens': itens.map((item) => item.toJson()).toList(),
        if (codigosCupom.isNotEmpty) 'codigosCupom': codigosCupom,
      },
    );

    return ResultadoElegibilidade.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
