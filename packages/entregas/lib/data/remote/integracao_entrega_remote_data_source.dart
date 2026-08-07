import 'package:core/remote_data_sourcers.dart';
import 'package:entregas/data/remote/dtos/entrega_dto.dart';
import 'package:entregas/domain/data/remote/i_integracao_entrega_remote_data_source.dart';
import 'package:entregas/domain/models/entrega.dart';

class IntegracaoEntregaRemoteDataSource extends RemoteDataSourceBase
    implements IIntegracaoEntregaRemoteDataSource {
  IntegracaoEntregaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/integracoes-entrega{path}';

  @override
  Future<EmpresaIntegracaoEntrega?> getConfiguracao() async {
    final response = await get(pathParameters: {'path': '/configuracao'});
    if (response.body == null) return null;
    return EmpresaIntegracaoEntregaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<EmpresaIntegracaoEntrega> salvarConfiguracao({
    required String provider,
    bool? ativo,
    Map<String, dynamic>? configuracao,
  }) async {
    final response = await post(
      pathParameters: {'path': '/configuracao'},
      body: {
        'provider': provider,
        if (ativo != null) 'ativo': ativo,
        if (configuracao != null) 'configuracao': configuracao,
      },
    );
    return EmpresaIntegracaoEntregaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<EstimativaEntrega> estimar({
    required EnderecoEntrega partida,
    required EnderecoEntrega destino,
    int? categoriaId,
    String? categoriaNome,
    String? data,
    String? hora,
    bool? comRetorno,
  }) async {
    final response = await get(
      pathParameters: {'path': '/estimar'},
      queryParameters: {
        'enderecoPartida': partida.endereco,
        'bairroPartida': partida.bairro,
        'cidadePartida': partida.cidade,
        'estadoPartida': partida.estado,
        'latPartida': '${partida.lat}',
        'lngPartida': '${partida.lng}',
        'enderecoDestino': destino.endereco,
        'bairroDestino': destino.bairro,
        'cidadeDestino': destino.cidade,
        'estadoDestino': destino.estado,
        'latDestino': '${destino.lat}',
        'lngDestino': '${destino.lng}',
        if (categoriaId != null) 'categoriaId': '$categoriaId',
        if (categoriaNome != null) 'categoriaNome': categoriaNome,
        if (data != null) 'data': data,
        if (hora != null) 'hora': hora,
        if (comRetorno != null) 'comRetorno': '$comRetorno',
      },
    );
    return EstimativaEntregaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<double> getSaldo() async {
    final response = await get(pathParameters: {'path': '/saldo'});
    final body = response.body as Map<String, dynamic>;
    return (body['saldo'] as num).toDouble();
  }

  @override
  Future<SolicitacaoEntrega> abrirSolicitacao({
    required int categoriaId,
    required String categoriaNome,
    String? formaPagamento,
    int? condutorIdentificacao,
    required EnderecoEntrega partida,
    required List<ParadaEntrega> paradas,
    bool? retorno,
    String? data,
    String? hora,
    int? antecedencia,
    double? valorEstimado,
  }) async {
    final response = await post(
      pathParameters: {'path': '/solicitacoes'},
      body: {
        'categoriaId': categoriaId,
        'categoriaNome': categoriaNome,
        if (formaPagamento != null) 'formaPagamento': formaPagamento,
        if (condutorIdentificacao != null)
          'condutorIdentificacao': condutorIdentificacao,
        'partida': (partida as EnderecoEntregaDto).toJson(),
        'paradas': paradas
            .map((parada) => (parada as ParadaEntregaDto).toJson())
            .toList(),
        if (retorno != null) 'retorno': retorno,
        if (data != null) 'data': data,
        if (hora != null) 'hora': hora,
        if (antecedencia != null) 'antecedencia': antecedencia,
        if (valorEstimado != null) 'valorEstimado': valorEstimado,
      },
    );
    return SolicitacaoEntregaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<List<RastreioEntrega>> getRastreio(int id) async {
    final response = await get(
      pathParameters: {'path': '/solicitacoes/$id/rastreio'},
    );
    return (response.body as List<dynamic>)
        .map((j) => RastreioEntregaDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SolicitacaoEntrega> cancelar(int id, {int? motivoId}) async {
    final response = await post(
      pathParameters: {'path': '/solicitacoes/$id/cancelar'},
      body: {if (motivoId != null) 'motivoId': motivoId},
    );
    return SolicitacaoEntregaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
