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
    DateTime? ultimaAtualizacaoInicio,
    DateTime? ultimaAtualizacaoFim,
  }) async {
    final pathParameters = {'tabelaDePrecoId': tabelaDePrecoId};
    int pagina = 1;

    List<PrecoDaReferencia> precosDaReferencia = [];
    while (true) {
      final queryParameters = <String, String>{'page': pagina.toString()};
      if (ultimaAtualizacaoInicio != null) {
        queryParameters['ultimaAtualizacaoInicio'] = ultimaAtualizacaoInicio
            .toIso8601String();
      }
      if (ultimaAtualizacaoFim != null) {
        queryParameters['ultimaAtualizacaoFim'] = ultimaAtualizacaoFim
            .toIso8601String();
      }

      final response = await get(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      );
      final precosDaReferenciaDto = PrecosDaReferenciaDto.fromJson(
        response.body,
      );
      if (precosDaReferenciaDto.items.isEmpty) {
        break;
      }
      precosDaReferencia.addAll(precosDaReferenciaDto.items);
      pagina++;
    }
    return precosDaReferencia;
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
  String get path =>
      '/v1/tabelas-de-precos/{tabelaDePrecoId}/referencias/{referenciaId}';
}
