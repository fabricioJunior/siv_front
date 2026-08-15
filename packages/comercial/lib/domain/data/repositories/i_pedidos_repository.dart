import 'package:comercial/models.dart';

abstract class IPedidosRepository {
  Future<List<Pedido>> recuperarPedidos();
  Future<Pedido> recuperarPedido(int id);
  Future<Pedido> criarPedido(Pedido pedido);
  Future<Pedido> atualizarPedido(Pedido pedido);
  Future<Pedido> aplicarDesconto(int id, {required double desconto});
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false});
  Future<void> marcarConferido(int id);
  Future<void> faturarPedido(int id, {required int caixaId});
  Future<void> cancelarPedido(int id, {required String motivoCancelamento});
  Future<Pedido> assumirPedido(int id, {required int funcionarioId});

  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required int formaDePagamentoId,
    required double valorEsperado,
    double? taxaAplicada,
  });
  Future<List<PedidoPagamento>> listarPagamentos(int id);
  Future<PedidoPagamento> confirmarPagamento(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  });
  Future<void> removerPagamento(int id, int pagamentoId);
  Future<PedidoPagamento> atualizarValorParaTrocoPagamento(
    int id,
    int pagamentoId, {
    required double valorParaTroco,
  });
  Future<void> chamarEntregador(int id);
  Future<void> confirmarEntrega(int id);
  Future<void> embalarPedido(int id);
  Future<(Pedido, List<Pedido>)> confirmarRetirada(int id, String codigo);
  Future<List<Pedido>> confirmarRetiradaLote(List<int> pedidoIds);
  Future<Pedido> criarTaxaEntrega(
    int id, {
    required double valorTaxaEntrega,
    required int enderecoEntregaId,
  });
  Future<List<PedidoEvento>> listarEventos(int id);
  Future<void> reenviarEmail(int id);

  Future<List<PedidoItem>> listarItens(int id);
  Future<PedidoItem> adicionarItem(
    int id, {
    required int produtoId,
    required double quantidade,
  });
  Future<void> removerItem(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  });
  Future<void> conferirItem(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  });
  Future<void> conferirItemPorCodigo(
    int id, {
    required String codigoBarras,
    required double quantidade,
  });
}
