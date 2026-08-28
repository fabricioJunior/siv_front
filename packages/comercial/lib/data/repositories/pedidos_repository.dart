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
  Future<Pedido> aplicarDesconto(int id, {required double desconto}) {
    return remoteDataSource.aplicarDesconto(id, desconto: desconto);
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
  Future<void> marcarConferido(int id) {
    return remoteDataSource.marcarConferido(id);
  }

  @override
  Future<Pedido> assumirPedido(int id, {required int funcionarioId}) {
    return remoteDataSource.assumirPedido(id, funcionarioId: funcionarioId);
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
  Future<List<Pedido>> recuperarPedidos({int page = 1, int limit = 30}) {
    return remoteDataSource.recuperarPedidos(page: page, limit: limit);
  }

  @override
  Future<PedidoPagamento> adicionarPagamento(
    int id, {
    required int formaDePagamentoId,
    required double valorEsperado,
    double? taxaAplicada,
  }) {
    return remoteDataSource.adicionarPagamento(
      id,
      formaDePagamentoId: formaDePagamentoId,
      valorEsperado: valorEsperado,
      taxaAplicada: taxaAplicada,
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
  Future<void> removerPagamento(int id, int pagamentoId) {
    return remoteDataSource.removerPagamento(id, pagamentoId);
  }

  @override
  Future<PedidoPagamento> atualizarValorParaTrocoPagamento(
    int id,
    int pagamentoId, {
    required double valorParaTroco,
  }) {
    return remoteDataSource.atualizarValorParaTrocoPagamento(
      id,
      pagamentoId,
      valorParaTroco: valorParaTroco,
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
  Future<void> embalarPedido(int id) {
    return remoteDataSource.embalarPedido(id);
  }

  @override
  Future<(Pedido, List<Pedido>)> confirmarRetirada(int id, String codigo) {
    return remoteDataSource.confirmarRetirada(id, codigo);
  }

  @override
  Future<List<Pedido>> confirmarRetiradaLote(List<int> pedidoIds) {
    return remoteDataSource.confirmarRetiradaLote(pedidoIds);
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
  Future<void> reenviarEmail(int id) {
    return remoteDataSource.reenviarEmail(id);
  }

  @override
  Future<void> reenviarEmailEmbalado(int id) {
    return remoteDataSource.reenviarEmailEmbalado(id);
  }

  @override
  Future<String> linkCompartilhamento(int id) {
    return remoteDataSource.linkCompartilhamento(id);
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

  @override
  Future<void> conferirItemPorCodigo(
    int id, {
    required String codigoBarras,
    required double quantidade,
  }) {
    return pedidoItemRemoteDataSource.conferirItemPorCodigo(
      id,
      codigoBarras: codigoBarras,
      quantidade: quantidade,
    );
  }
}
