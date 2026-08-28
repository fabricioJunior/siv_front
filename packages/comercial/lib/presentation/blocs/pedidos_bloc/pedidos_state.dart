part of 'pedidos_bloc.dart';

class PedidosState extends Equatable {
  final List<Pedido> pedidos;
  final List<Pedido> filtrados;
  final String busca;
  final Set<String> situacoesFiltro;
  final String? erro;
  final PedidosStep step;
  final int paginaAtual;
  final bool temMaisPaginas;
  final bool carregandoMais;

  const PedidosState({
    required this.pedidos,
    required this.filtrados,
    required this.busca,
    required this.step,
    this.situacoesFiltro = const {},
    this.erro,
    this.paginaAtual = 1,
    this.temMaisPaginas = false,
    this.carregandoMais = false,
  });

  const PedidosState.initial()
      : pedidos = const [],
        filtrados = const [],
        busca = '',
        situacoesFiltro = const {},
        erro = null,
        step = PedidosStep.inicial,
        paginaAtual = 1,
        temMaisPaginas = false,
        carregandoMais = false;

  PedidosState copyWith({
    List<Pedido>? pedidos,
    List<Pedido>? filtrados,
    String? busca,
    Set<String>? situacoesFiltro,
    String? erro,
    PedidosStep? step,
    int? paginaAtual,
    bool? temMaisPaginas,
    bool? carregandoMais,
  }) {
    return PedidosState(
      pedidos: pedidos ?? this.pedidos,
      filtrados: filtrados ?? this.filtrados,
      busca: busca ?? this.busca,
      situacoesFiltro: situacoesFiltro ?? this.situacoesFiltro,
      erro: erro,
      step: step ?? this.step,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      temMaisPaginas: temMaisPaginas ?? this.temMaisPaginas,
      carregandoMais: carregandoMais ?? this.carregandoMais,
    );
  }

  @override
  List<Object?> get props => [
        pedidos,
        filtrados,
        busca,
        situacoesFiltro,
        erro,
        step,
        paginaAtual,
        temMaisPaginas,
        carregandoMais,
      ];
}

enum PedidosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
