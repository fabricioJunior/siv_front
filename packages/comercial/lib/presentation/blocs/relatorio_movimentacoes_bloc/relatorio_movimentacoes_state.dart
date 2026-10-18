part of 'relatorio_movimentacoes_bloc.dart';

enum RelatorioMovimentacoesStep { inicial, carregando, sucesso, falha }

class RelatorioMovimentacoesState {
  final RelatorioMovimentacoesStep step;
  final DateTime inicio;
  final DateTime fim;
  final Set<String> tipos;
  final String busca;
  final List<MovimentacaoItem> items;
  final Map<String, int> contagemPorTipo;
  final int page;
  final int totalPages;
  final bool carregandoMais;
  final String? erro;

  const RelatorioMovimentacoesState({
    required this.step,
    required this.inicio,
    required this.fim,
    this.tipos = const {},
    this.busca = '',
    this.items = const [],
    this.contagemPorTipo = const {},
    this.page = 1,
    this.totalPages = 1,
    this.carregandoMais = false,
    this.erro,
  });

  bool get temMais => page < totalPages;

  RelatorioMovimentacoesState copyWith({
    RelatorioMovimentacoesStep? step,
    DateTime? inicio,
    DateTime? fim,
    Set<String>? tipos,
    String? busca,
    List<MovimentacaoItem>? items,
    Map<String, int>? contagemPorTipo,
    int? page,
    int? totalPages,
    bool? carregandoMais,
    String? erro,
  }) =>
      RelatorioMovimentacoesState(
        step: step ?? this.step,
        inicio: inicio ?? this.inicio,
        fim: fim ?? this.fim,
        tipos: tipos ?? this.tipos,
        busca: busca ?? this.busca,
        items: items ?? this.items,
        contagemPorTipo: contagemPorTipo ?? this.contagemPorTipo,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        carregandoMais: carregandoMais ?? this.carregandoMais,
        erro: erro,
      );
}
