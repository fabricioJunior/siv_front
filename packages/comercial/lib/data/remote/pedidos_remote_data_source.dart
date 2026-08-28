import 'package:comercial/data/remote/dtos/pedido_dto.dart';
import 'package:comercial/data/remote/dtos/pedido_evento_dto.dart';
import 'package:comercial/data/remote/dtos/pedido_pagamento_dto.dart';
import 'package:comercial/domain/data/remote/i_pedidos_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class PedidosRemoteDataSource extends RemoteDataSourceBase
    implements IPedidosRemoteDataSource {
  PedidosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pedidos/{id}';

  @override
  Future<Pedido> atualizarPedido(Pedido pedido) async {
    final response = await put(
      pathParameters: {'id': pedido.id.toString()},
      body: PedidoDto.fromModel(pedido).toUpdateJson(),
    );
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Pedido> aplicarDesconto(int id, {required double desconto}) async {
    final response = await put(
      pathParameters: {'id': '$id/desconto'},
      body: {'desconto': desconto},
    );
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> cancelarPedido(
    int id, {
    required String motivoCancelamento,
  }) async {
    await put(
      pathParameters: {'id': '$id/cancelar'},
      body: {'motivoCancelamento': motivoCancelamento},
    );
  }

  @override
  Future<void> conferirPedido(
    int id, {
    bool processarComDivergencia = false,
  }) async {
    await put(
      pathParameters: {'id': '$id/conferir'},
      queryParameters: {
        'processarComDivegencia': processarComDivergencia.toString(),
      },
      body: {},
    );
  }

  @override
  Future<void> marcarConferido(int id) async {
    await put(pathParameters: {'id': '$id/marcar-conferido'}, body: {});
  }

  @override
  Future<Pedido> assumirPedido(int id, {required int funcionarioId}) async {
    final response = await put(
      pathParameters: {'id': '$id/assumir'},
      body: {'funcionarioId': funcionarioId},
    );
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Pedido> criarPedido(Pedido pedido) async {
    final response =
        await post(body: PedidoDto.fromModel(pedido).toCreateJson());
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> faturarPedido(int id, {required int caixaId}) async {
    await put(
      pathParameters: {'id': '$id/faturar'},
      body: {'caixaId': caixaId},
    );
  }

  @override
  Future<Pedido> recuperarPedido(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Pedido>> recuperarPedidos({int page = 1, int limit = 30}) async {
    final response = await get(
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    return (response.body as List<dynamic>)
        .map((json) => PedidoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required int formaDePagamentoId,
    required double valorEsperado,
    double? taxaAplicada,
  }) async {
    final response = await post(
      pathParameters: {'id': '$id/pagamentos'},
      body: {
        'formaDePagamentoId': formaDePagamentoId,
        'valorEsperado': valorEsperado,
        if (taxaAplicada != null) 'taxaAplicada': taxaAplicada,
      },
    );
    return PedidoPagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<PedidoPagamento>> listarPagamentos(int id) async {
    final response = await get(pathParameters: {'id': '$id/pagamentos'});
    return (response.body as List<dynamic>)
        .map(
          (json) => PedidoPagamentoDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<PedidoPagamento> confirmarPagamento(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  }) async {
    final response = await put(
      pathParameters: {'id': '$id/pagamentos/$pagamentoId/confirmar'},
      body: {'valorConfirmado': valorConfirmado},
    );
    return PedidoPagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> removerPagamento(int id, int pagamentoId) async {
    await delete(pathParameters: {'id': '$id/pagamentos/$pagamentoId'});
  }

  @override
  Future<PedidoPagamento> atualizarValorParaTrocoPagamento(
    int id,
    int pagamentoId, {
    required double valorParaTroco,
  }) async {
    final response = await put(
      pathParameters: {
        'id': '$id/pagamentos/$pagamentoId/valor-para-troco',
      },
      body: {'valorParaTroco': valorParaTroco},
    );
    return PedidoPagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> chamarEntregador(int id) async {
    await put(
      pathParameters: {'id': '$id/entregador/chamar'},
      body: {},
    );
  }

  @override
  Future<void> confirmarEntrega(int id) async {
    await put(
      pathParameters: {'id': '$id/entregador/confirmar-entrega'},
      body: {},
    );
  }

  @override
  Future<void> embalarPedido(int id) async {
    await put(
      pathParameters: {'id': '$id/embalar'},
      body: {},
    );
  }

  @override
  Future<(Pedido, List<Pedido>)> confirmarRetirada(
    int id,
    String codigo,
  ) async {
    final response = await put(
      pathParameters: {'id': '$id/confirmar-retirada'},
      body: {'codigo': codigo},
    );
    final json = response.body as Map<String, dynamic>;
    final pedido = PedidoDto.fromJson(json['pedido'] as Map<String, dynamic>);
    final outrosPedidosPendentes =
        (json['outrosPedidosPendentes'] as List<dynamic>? ?? [])
            .map((item) => PedidoDto.fromJson(item as Map<String, dynamic>))
            .toList();
    return (pedido, outrosPedidosPendentes);
  }

  @override
  Future<List<Pedido>> confirmarRetiradaLote(List<int> pedidoIds) async {
    final response = await put(
      pathParameters: {'id': 'confirmar-retirada-lote'},
      body: {'pedidoIds': pedidoIds},
    );
    return (response.body as List<dynamic>)
        .map((json) => PedidoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Pedido> criarTaxaEntrega(
    int id, {
    required double valorTaxaEntrega,
    required int enderecoEntregaId,
  }) async {
    final response = await post(
      pathParameters: {'id': '$id/taxa-entrega'},
      body: {
        'valorTaxaEntrega': valorTaxaEntrega,
        'enderecoEntregaId': enderecoEntregaId,
      },
    );
    return PedidoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<PedidoEvento>> listarEventos(int id) async {
    final response = await get(pathParameters: {'id': '$id/eventos'});
    return (response.body as List<dynamic>)
        .map((json) => PedidoEventoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> reenviarEmail(int id) async {
    await put(
      pathParameters: {'id': '$id/reenviar-email'},
      body: {},
    );
  }

  @override
  Future<void> reenviarEmailEmbalado(int id) async {
    await put(
      pathParameters: {'id': '$id/reenviar-email-embalado'},
      body: {},
    );
  }

  @override
  Future<String> linkCompartilhamento(int id) async {
    final response = await get(pathParameters: {'id': '$id/link-compartilhamento'});
    return (response.body as Map<String, dynamic>)['url'] as String;
  }
}
