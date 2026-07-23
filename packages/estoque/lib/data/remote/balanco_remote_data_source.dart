import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/data/remote/dtos/balanco_dto.dart';
import 'package:estoque/data/remote/dtos/balanco_itens_dto.dart';
import 'package:estoque/domain/data/remote/i_balanco_remote_data_source.dart';
import 'package:estoque/domain/models/balanco.dart';

class BalancoRemoteDataSource extends RemoteDataSourceBase
    implements IBalancoRemoteDataSource {
  BalancoRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<Balanco> criarBalanco({required String? observacao}) async {
    final body = CreateBalancoDto(observacao: observacao);
    final response = await post(body: body.toJson());
    return _mapDtoToBalanco(BalancoDto.fromJson(response.body));
  }

  @override
  Future<List<Balanco>> listarBalancos({
    required String? situacao,
    required int page,
    required int limit,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (situacao != null) {
      queryParams['situacao'] = situacao;
    }

    final response = await get(queryParameters: queryParams);
    final data = response.body as Map<String, dynamic>;
    final items = data['items'] as List;
    return items
        .map((json) => _mapDtoToBalanco(BalancoDto.fromJson(json)))
        .toList();
  }

  @override
  Future<Balanco> obterBalanco({required int balancoId}) async {
    final response = await get(pathParameters: {'path': '/$balancoId'});
    return _mapDtoToBalanco(BalancoDto.fromJson(response.body));
  }

  @override
  Future<Balanco> atualizarBalanco({
    required int balancoId,
    required String? observacao,
  }) async {
    final body = UpdateBalancoDto(observacao: observacao);
    final response = await put(
      pathParameters: {'path': '/$balancoId'},
      body: body.toJson(),
    );
    return _mapDtoToBalanco(BalancoDto.fromJson(response.body));
  }

  @override
  Future<Balanco> encerrarBalanco({
    required int balancoId,
    required String? observacao,
  }) async {
    final body = EncerrarBalancoDto(observacao: observacao);
    final response = await put(
      pathParameters: {'path': '/$balancoId/encerrar'},
      body: body.toJson(),
    );
    return _mapDtoToBalanco(BalancoDto.fromJson(response.body));
  }

  @override
  Future<Balanco> cancelarBalanco({
    required int balancoId,
    required String motivo,
  }) async {
    final body = CancelarBalancoDto(motivo: motivo);
    final response = await put(
      pathParameters: {'path': '/$balancoId/cancelar'},
      body: body.toJson(),
    );
    return _mapDtoToBalanco(BalancoDto.fromJson(response.body));
  }

  @override
  Future<Map<String, dynamic>> obterResumo({required int balancoId}) async {
    final response = await get(pathParameters: {'path': '/$balancoId/resumo'});
    return response.body as Map<String, dynamic>;
  }

  @override
  Future<BalancoItem> adicionarItem({
    required int balancoId,
    required int produtoId,
  }) async {
    final body = AddRemoveBalancoItemDto(produtoId: produtoId);
    final response = await post(
      pathParameters: {'path': '/$balancoId/itens'},
      body: body.toJson(),
    );
    return _mapDtoToBalancoItem(BalancoItemDto.fromJson(response.body));
  }

  @override
  Future<void> adicionarMultiplosItensPorReferencia({
    required int balancoId,
    required List<int> referenciaIds,
  }) async {
    await post(
      pathParameters: {'path': '/$balancoId/itens/referencias'},
      body: {'referenciaIds': referenciaIds},
    );
  }

  @override
  Future<List<BalancoItem>> listarItensDoBalanco({
    required int balancoId,
    int page = 1,
    int limit = 25,
    bool? comDivergencia,
    List<String>? referencias,
    List<String>? ordenacao,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (comDivergencia != null) {
      queryParams['comDivergencia'] = comDivergencia.toString();
    }
    if (referencias != null && referencias.isNotEmpty) {
      queryParams['referencias'] = referencias.join(',');
    }
    if (ordenacao != null && ordenacao.isNotEmpty) {
      queryParams['ordenacao'] = ordenacao.join(',');
    }
    final response = await get(
      pathParameters: {'path': '/$balancoId/itens'},
      queryParameters: queryParams,
    );
    final items = BalancoItensDto.fromJson(response.body).itens;
    return items.map((item) => _mapDtoToBalancoItem(item)).toList();
  }

  @override
  Future<void> removerItemDoBalanco({
    required int balancoId,
    required int produtoId,
  }) async {
    await delete(pathParameters: {'path': '/$balancoId/itens/$produtoId'});
  }

  @override
  Future<BalancoLote> criarLote({
    required int balancoId,
    required String lote,
    required String? observacao,
  }) async {
    final body = CreateBalancoLoteDto(lote: lote, observacao: observacao);
    final response = await post(
      pathParameters: {'path': '/$balancoId/lotes'},
      body: body.toJson(),
    );
    return _mapDtoToBalancoLote(BalancoLoteDto.fromJson(response.body));
  }

  @override
  Future<List<BalancoLote>> listarLotes({required int balancoId}) async {
    final response = await get(pathParameters: {'path': '/$balancoId/lotes'});
    final items = response.body as List;
    return items
        .map((json) => _mapDtoToBalancoLote(BalancoLoteDto.fromJson(json)))
        .toList();
  }

  @override
  Future<BalancoLote> atualizarLote({
    required int balancoId,
    required int loteId,
    required String? lote,
    required String? observacao,
  }) async {
    final body = UpdateBalancoLoteDto(lote: lote, observacao: observacao);
    final response = await put(
      pathParameters: {'path': '/$balancoId/lotes/$loteId'},
      body: body.toJson(),
    );
    return _mapDtoToBalancoLote(BalancoLoteDto.fromJson(response.body));
  }

  @override
  Future<BalancoLote> cancelarLote({
    required int balancoId,
    required int loteId,
    required String motivo,
  }) async {
    final body = CancelarBalancoLoteDto(motivo: motivo);
    final response = await put(
      pathParameters: {'path': '/$balancoId/lotes/$loteId/cancelar'},
      body: body.toJson(),
    );
    return _mapDtoToBalancoLote(BalancoLoteDto.fromJson(response.body));
  }

  @override
  Future<BalancoLoteItem> adicionarItemAoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
    required double quantidadeContada,
  }) async {
    final body = AddRemoveBalancoLoteItemDto(
      produtoId: produtoId,
      quantidadeContada: quantidadeContada,
    );
    final response = await post(
      pathParameters: {'path': '/$balancoId/lotes/$loteId/itens'},
      body: body.toJson(),
    );
    return _mapDtoToBalancoLoteItem(BalancoLoteItemDto.fromJson(response.body));
  }

  @override
  Future<void> adicionarMultiplosItensAoLote({
    required int balancoId,
    required int loteId,
    required List<Map<String, dynamic>> itens,
  }) async {
    final body = itens
        .map(
          (item) => AddRemoveBalancoLoteItemDto(
            produtoId: item['produtoId'],
            quantidadeContada: item['quantidadeContada'],
          ),
        )
        .map((dto) => dto.toJson())
        .toList();
    await put(
      pathParameters: {'path': '/$balancoId/lotes/$loteId/itens'},
      body: body,
    );
  }

  @override
  Future<List<BalancoLoteItem>> listarItensDoLote({
    required int balancoId,
    required int loteId,
  }) async {
    final response = await get(
      pathParameters: {'path': '/$balancoId/lotes/$loteId/itens'},
    );
    final items = response.body as List;
    return items
        .map(
          (json) => _mapDtoToBalancoLoteItem(BalancoLoteItemDto.fromJson(json)),
        )
        .toList();
  }

  @override
  Future<void> removerItemDoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
  }) async {
    await delete(
      pathParameters: {'path': '/$balancoId/lotes/$loteId/itens/$produtoId'},
    );
  }

  @override
  Future<void> calcularItensDoBalanco({required int balancoId}) async {
    await post(
      body: {},
      pathParameters: {'path': '/$balancoId/itens/calcular'},
    );
  }

  @override
  Future<Balanco?> obterBalancoEmAndamento() async {
    final response = await get(pathParameters: {'path': '/em-andamento'});
    final data = response.body as Map<String, dynamic>;
    final balancoJson = data['balanco'] as Map<String, dynamic>?;
    if (data['emAndamento'] != true || balancoJson == null) {
      return null;
    }
    return _mapDtoToBalanco(BalancoDto.fromJson(balancoJson));
  }

  // ===== MAPPERS =====

  Balanco _mapDtoToBalanco(BalancoDto dto) {
    return Balanco(
      id: dto.id,
      empresaId: dto.empresaId,
      data: dto.data,
      observacao: dto.observacao,
      situacao: dto.situacao,
      motivoCancelamento: dto.motivoCancelamento,
      operadorId: dto.operadorId,
      criadoEm: dto.criadoEm,
      atualizadoEm: dto.atualizadoEm,
    );
  }

  BalancoItem _mapDtoToBalancoItem(BalancoItemDto dto) {
    return BalancoItem(
      empresaId: dto.empresaId,
      balancoId: dto.balancoId,
      sequencia: dto.sequencia,
      produtoId: dto.produtoId,
      quantidadeOriginal: dto.quantidadeOriginal,
      quantidadeContada: dto.quantidadeContada,
      operadorId: dto.operadorId,
      produtoNome: dto.produtoNome,
      tamanho: dto.tamanho,
      cor: dto.cor,
      referencia: dto.referencia,
      criadoEm: dto.criadoEm,
      atualizadoEm: dto.atualizadoEm,
    );
  }

  BalancoLote _mapDtoToBalancoLote(BalancoLoteDto dto) {
    return BalancoLote(
      id: dto.id,
      empresaId: dto.empresaId,
      balancoId: dto.balancoId,
      lote: dto.lote,
      observacao: dto.observacao,
      situacao: dto.situacao,
      motivoCancelamento: dto.motivoCancelamento,
      operadorId: dto.operadorId,
      criadoEm: dto.criadoEm,
      atualizadoEm: dto.atualizadoEm,
    );
  }

  BalancoLoteItem _mapDtoToBalancoLoteItem(BalancoLoteItemDto dto) {
    return BalancoLoteItem(
      empresaId: dto.empresaId,
      balancoId: dto.balancoId,
      loteId: dto.loteId,
      sequencia: dto.sequencia,
      produtoId: dto.produtoId,
      quantidadeContada: dto.quantidadeContada,
      operadorId: dto.operadorId,
      criadoEm: dto.criadoEm,
      atualizadoEm: dto.atualizadoEm,
    );
  }

  @override
  String get path => '/v1/balancos{path}';
}
