import 'package:comercial/models.dart';

abstract class IPedidosRepository {
  Future<List<Pedido>> recuperarPedidos();
  Future<Pedido> recuperarPedido(int id);
  Future<Pedido> criarPedido(Pedido pedido);
  Future<Pedido> atualizarPedido(Pedido pedido);
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false});
  Future<void> faturarPedido(int id, {required int caixaId});
  Future<void> cancelarPedido(int id, {required String motivoCancelamento});

  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required String tipo,
    int? pagamentoAvulsoId,
    String? formaPagamento,
    required double valorEsperado,
  });
  Future<List<PedidoPagamento>> listarPagamentos(int id);
  Future<PedidoPagamento> confirmarPagamento(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  });
  Future<void> chamarEntregador(int id);
  Future<void> confirmarEntrega(int id);
  Future<Pedido> criarTaxaEntrega(
    int id, {
    required double valorTaxaEntrega,
    required int enderecoEntregaId,
  });
  Future<List<PedidoEvento>> listarEventos(int id);

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
}
