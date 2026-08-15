part of 'pedidos_bloc.dart';

class PedidosState extends Equatable {
  final List<Pedido> pedidos;
  final List<Pedido> filtrados;
  final String busca;
  final String? situacaoFiltro;
  final String? erro;
  final PedidosStep step;

  const PedidosState({
    required this.pedidos,
    required this.filtrados,
    required this.busca,
    required this.step,
    this.situacaoFiltro,
    this.erro,
  });

  const PedidosState.initial()
      : pedidos = const [],
        filtrados = const [],
        busca = '',
        situacaoFiltro = null,
        erro = null,
        step = PedidosStep.inicial;

  PedidosState copyWith({
    List<Pedido>? pedidos,
    List<Pedido>? filtrados,
    String? busca,
    String? situacaoFiltro,
    bool limparSituacaoFiltro = false,
    String? erro,
    PedidosStep? step,
  }) {
    return PedidosState(
      pedidos: pedidos ?? this.pedidos,
      filtrados: filtrados ?? this.filtrados,
      busca: busca ?? this.busca,
      situacaoFiltro:
          limparSituacaoFiltro ? null : (situacaoFiltro ?? this.situacaoFiltro),
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [pedidos, filtrados, busca, situacaoFiltro, erro, step];
}

enum PedidosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
