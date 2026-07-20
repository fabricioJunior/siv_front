import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class PedidosRepository implements IPedidosRepository {
  final IPedidosRemoteDataSource remoteDataSource;
  final IPedidoItemRemoteDataSource pedidoItemRemoteDataSource;

  PedidosRepository({
    required this.remoteDataSource,
    required this.pedidoItemRemoteDataSource,
  });

  @override
  Future<Pedido> atualizarPedido(Pedido pedido) {
    return remoteDataSource.atualizarPedido(pedido);
  }

  @override
  Future<void> cancelarPedido(
    int id, {
    required String motivoCancelamento,
  }) {
    return remoteDataSource.cancelarPedido(
      id,
      motivoCancelamento: motivoCancelamento,
    );
  }

  @override
  Future<void> conferirPedido(int id, {bool processarComDivergencia = false}) {
    return remoteDataSource.conferirPedido(
      id,
      processarComDivergencia: processarComDivergencia,
    );
  }

  @override
  Future<Pedido> criarPedido(Pedido pedido) {
    return remoteDataSource.criarPedido(pedido);
  }

  @override
  Future<void> faturarPedido(int id, {required int caixaId}) {
    return remoteDataSource.faturarPedido(id, caixaId: caixaId);
  }

  @override
  Future<Pedido> recuperarPedido(int id) {
    return remoteDataSource.recuperarPedido(id);
  }

  @override
  Future<List<Pedido>> recuperarPedidos() {
    return remoteDataSource.recuperarPedidos();
  }

  @override
  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required String tipo,
    int? pagamentoAvulsoId,
    String? formaPagamento,
    required double valorEsperado,
  }) {
    return remoteDataSource.adicionarPagamento(
      id,
      tipo: tipo,
      pagamentoAvulsoId: pagamentoAvulsoId,
      formaPagamento: formaPagamento,
      valorEsperado: valorEsperado,
    );
  }

  @override
  Future<List<PedidoPagamento>> listarPagamentos(int id) {
    return remoteDataSource.listarPagamentos(id);
  }

  @override
  Future<PedidoPagamento> confirmarPagamento(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  }) {
    return remoteDataSource.confirmarPagamento(
      id,
      pagamentoId,
      valorConfirmado: valorConfirmado,
    );
  }

  @override
  Future<void> chamarEntregador(int id) {
    return remoteDataSource.chamarEntregador(id);
  }

  @override
  Future<void> confirmarEntrega(int id) {
    return remoteDataSource.confirmarEntrega(id);
  }

  @override
  Future<Pedido> criarTaxaEntrega(
    int id, {
    required double valorTaxaEntrega,
    required int enderecoEntregaId,
  }) {
    return remoteDataSource.criarTaxaEntrega(
      id,
      valorTaxaEntrega: valorTaxaEntrega,
      enderecoEntregaId: enderecoEntregaId,
    );
  }

  @override
  Future<List<PedidoEvento>> listarEventos(int id) {
    return remoteDataSource.listarEventos(id);
  }

  @override
  Future<List<PedidoItem>> listarItens(int id) {
    return pedidoItemRemoteDataSource.listarItens(id);
  }

  @override
  Future<PedidoItem> adicionarItem(
    int id, {
    required int produtoId,
    required double quantidade,
  }) {
    return pedidoItemRemoteDataSource.adicionarItem(
      id,
      produtoId: produtoId,
      quantidade: quantidade,
    );
  }

  @override
  Future<void> removerItem(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) {
    return pedidoItemRemoteDataSource.removerItem(
      id,
      produtoId: produtoId,
      sequencia: sequencia,
      quantidade: quantidade,
    );
  }

  @override
  Future<void> conferirItem(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) {
    return pedidoItemRemoteDataSource.conferirItem(
      id,
      produtoId: produtoId,
      sequencia: sequencia,
      quantidade: quantidade,
    );
  }
}
