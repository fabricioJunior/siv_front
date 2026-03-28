import 'package:core/remote_data_sourcers.dart';
import 'package:precos/data/remote/dtos/preco_da_referencia_dto.dart';
import 'package:precos/data/remote/dtos/precos_da_referencia_dto.dart';
import 'package:precos/domain/data/remote/i_precos_de_referencias_remote_data_source.dart';
import 'package:precos/models.dart';

class PrecosDeReferenciasRemoteDataSource extends RemoteDataSourceBase
    implements IPrecosDeReferenciasRemoteDataSource {
  PrecosDeReferenciasRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<PrecoDaReferencia> atualizarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) async {
    final pathParameters = {
      'tabelaDePrecoId': tabelaDePrecoId,
      'referenciaId': referenciaId,
    };
    final body = {'valor': valor};
    final response = await put(pathParameters: pathParameters, body: body);
    return PrecoDaReferenciaDto.fromJson(response.body);
  }

  @override
  Future<PrecoDaReferencia> criarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) async {
    final pathParameters = {'tabelaDePrecoId': tabelaDePrecoId};
    final body = {'valor': valor, 'referenciaId': referenciaId};
    final response = await post(pathParameters: pathParameters, body: body);
    return PrecoDaReferenciaDto.fromJson(response.body);
  }

  @override
  Future<PrecoDaReferencia> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) async {
    final pathParameters = {
      'tabelaDePrecoId': tabelaDePrecoId,
      'referenciaId': referenciaId,
    };
    final response = await get(pathParameters: pathParameters);
    return PrecoDaReferenciaDto.fromJson(response.body);
  }

  @override
  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  }) async {
    final pathParameters = {'tabelaDePrecoId': tabelaDePrecoId};
    final response = await get(pathParameters: pathParameters);
    return PrecosDaReferenciaDto.fromJson(response.body).items;
  }

  @override
  Future<void> removerPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    final pathParameters = {
      'tabelaDePrecoId': tabelaDePrecoId,
      'referenciaId': referenciaId,
    };
    return delete(pathParameters: pathParameters);
  }

  @override
  String get path => '/v1/tabelas-de-precos/{tabelaDePrecoId}/referencias';
}
