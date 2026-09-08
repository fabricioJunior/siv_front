part of 'pedidos_bloc.dart';

class PedidosState extends Equatable {
  final List<Pedido> pedidos;
  final List<Pedido> filtrados;
  final String busca;
  final Set<String> situacoesFiltro;
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? erro;
  final PedidosStep step;
  final int paginaAtual;
  final bool temMaisPaginas;
  final bool carregandoMais;
  final int? pedidoSelecionadoId;
  final List<PedidoItem> itensDoPedidoSelecionado;
  final bool carregandoItensDoPedidoSelecionado;

  const PedidosState({
    required this.pedidos,
    required this.filtrados,
    required this.busca,
    required this.step,
    this.situacoesFiltro = const {},
    this.dataInicial,
    this.dataFinal,
    this.erro,
    this.paginaAtual = 1,
    this.temMaisPaginas = false,
    this.carregandoMais = false,
    this.pedidoSelecionadoId,
    this.itensDoPedidoSelecionado = const [],
    this.carregandoItensDoPedidoSelecionado = false,
  });

  const PedidosState.initial()
      : pedidos = const [],
        filtrados = const [],
        busca = '',
        situacoesFiltro = const {},
        dataInicial = null,
        dataFinal = null,
        erro = null,
        step = PedidosStep.inicial,
        paginaAtual = 1,
        temMaisPaginas = false,
        carregandoMais = false,
        pedidoSelecionadoId = null,
        itensDoPedidoSelecionado = const [],
        carregandoItensDoPedidoSelecionado = false;

  Pedido? get pedidoSelecionado {
    if (pedidoSelecionadoId == null) return null;
    for (final pedido in pedidos) {
      if (pedido.id == pedidoSelecionadoId) return pedido;
    }
    return null;
  }

  PedidosState copyWith({
    List<Pedido>? pedidos,
    List<Pedido>? filtrados,
    String? busca,
    Set<String>? situacoesFiltro,
    Object? dataInicial = _naoInformado,
    Object? dataFinal = _naoInformado,
    String? erro,
    PedidosStep? step,
    int? paginaAtual,
    bool? temMaisPaginas,
    bool? carregandoMais,
    Object? pedidoSelecionadoId = _naoInformado,
    List<PedidoItem>? itensDoPedidoSelecionado,
    bool? carregandoItensDoPedidoSelecionado,
  }) {
    return PedidosState(
      pedidos: pedidos ?? this.pedidos,
      filtrados: filtrados ?? this.filtrados,
      busca: busca ?? this.busca,
      situacoesFiltro: situacoesFiltro ?? this.situacoesFiltro,
      dataInicial: identical(dataInicial, _naoInformado)
          ? this.dataInicial
          : dataInicial as DateTime?,
      dataFinal: identical(dataFinal, _naoInformado)
          ? this.dataFinal
          : dataFinal as DateTime?,
      erro: erro,
      step: step ?? this.step,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      temMaisPaginas: temMaisPaginas ?? this.temMaisPaginas,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      pedidoSelecionadoId: identical(pedidoSelecionadoId, _naoInformado)
          ? this.pedidoSelecionadoId
          : pedidoSelecionadoId as int?,
      itensDoPedidoSelecionado:
          itensDoPedidoSelecionado ?? this.itensDoPedidoSelecionado,
      carregandoItensDoPedidoSelecionado:
          carregandoItensDoPedidoSelecionado ??
              this.carregandoItensDoPedidoSelecionado,
    );
  }

  @override
  List<Object?> get props => [
        pedidos,
        filtrados,
        busca,
        situacoesFiltro,
        dataInicial,
        dataFinal,
        erro,
        step,
        paginaAtual,
        temMaisPaginas,
        carregandoMais,
        pedidoSelecionadoId,
        itensDoPedidoSelecionado,
        carregandoItensDoPedidoSelecionado,
      ];
}

const Object _naoInformado = Object();

enum PedidosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
