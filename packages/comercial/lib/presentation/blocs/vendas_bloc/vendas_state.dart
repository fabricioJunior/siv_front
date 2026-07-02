part of 'vendas_bloc.dart';

class VendasState extends Equatable {
  final List<Romaneio> vendas;
  final String searchTerm;
  final int? caixaId;
  final DateTime? dataHoraInicial;
  final DateTime? dataHoraFinal;
  final String? erro;
  final VendasStep step;

  const VendasState({
    required this.vendas,
    this.searchTerm = '',
    this.caixaId,
    this.dataHoraInicial,
    this.dataHoraFinal,
    required this.step,
    this.erro,
  });

  const VendasState.initial()
      : vendas = const [],
        searchTerm = '',
        caixaId = null,
        dataHoraInicial = null,
        dataHoraFinal = null,
        erro = null,
        step = VendasStep.inicial;

  double get valorTotal =>
      vendas.fold(0, (total, venda) => total + (venda.valorLiquido ?? 0));

  VendasState copyWith({
    List<Romaneio>? vendas,
    String? searchTerm,
    int? caixaId,
    bool limparCaixaId = false,
    DateTime? dataHoraInicial,
    bool limparDataHoraInicial = false,
    DateTime? dataHoraFinal,
    bool limparDataHoraFinal = false,
    String? erro,
    VendasStep? step,
  }) {
    return VendasState(
      vendas: vendas ?? this.vendas,
      searchTerm: searchTerm ?? this.searchTerm,
      caixaId: limparCaixaId ? null : (caixaId ?? this.caixaId),
      dataHoraInicial: limparDataHoraInicial
          ? null
          : (dataHoraInicial ?? this.dataHoraInicial),
      dataHoraFinal:
          limparDataHoraFinal ? null : (dataHoraFinal ?? this.dataHoraFinal),
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        vendas,
        searchTerm,
        caixaId,
        dataHoraInicial,
        dataHoraFinal,
        erro,
        step,
      ];
}

enum VendasStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
