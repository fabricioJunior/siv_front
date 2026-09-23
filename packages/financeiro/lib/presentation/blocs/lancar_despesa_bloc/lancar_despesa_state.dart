part of 'lancar_despesa_bloc.dart';

enum ModoLancamentoDespesa { avulsa, parcelada, recorrente }

class LancarDespesaState extends Equatable {
  final int? empresaId;
  final int? caixaId;
  final List<CategoriaDespesa> categorias;
  final List<OrigemPagamentoDespesa> origens;
  final List<FormaDePagamento> formasDePagamento;
  final ModoLancamentoDespesa modo;
  final String? descricao;
  final double? valor;
  final int? categoriaId;
  final int? origemPagamentoId;
  final int? formaPagamentoId;
  final DateTime? dataPagamento;
  final DateTime? dataInicial;
  final bool pulouPorFechamento;
  final int? diaVencimento;
  final int? parcelas;
  final Despesa? despesaCriada;
  final String? erro;
  final LancarDespesaStep step;

  const LancarDespesaState({
    this.empresaId,
    this.caixaId,
    this.categorias = const [],
    this.origens = const [],
    this.formasDePagamento = const [],
    this.modo = ModoLancamentoDespesa.avulsa,
    this.descricao,
    this.valor,
    this.categoriaId,
    this.origemPagamentoId,
    this.formaPagamentoId,
    this.dataPagamento,
    this.dataInicial,
    this.pulouPorFechamento = false,
    this.diaVencimento,
    this.parcelas,
    this.despesaCriada,
    this.erro,
    required this.step,
  });

  /// Categoria só ativas -- o cadastro pode ter inativas, aqui não entram.
  List<CategoriaDespesa> get categoriasAtivas =>
      categorias.where((c) => !c.inativa).toList();

  OrigemPagamentoDespesa? get origemSelecionada {
    for (final origem in origens) {
      if (origem.id == origemPagamentoId) return origem;
    }
    return null;
  }

  bool get origemEhCredito =>
      origemSelecionada?.tipo.diaVencimentoObrigatorio ?? false;

  /// Preview das parcelas no modo parcelado: número, data e valor de cada
  /// uma -- a 1ª data é `dataPagamento` (hoje ou vencimento do cartão), as
  /// seguintes mês a mês com clamp de fim de mês.
  List<(int, DateTime)> get previewParcelas {
    if (modo != ModoLancamentoDespesa.parcelada) return const [];
    final total = parcelas;
    final primeira = dataPagamento;
    if (total == null || total <= 1 || primeira == null) return const [];
    return [for (var i = 0; i < total; i++) (i + 1, vencimentoNoMes(primeira, i))];
  }

  LancarDespesaState copyWith({
    int? empresaId,
    int? caixaId,
    List<CategoriaDespesa>? categorias,
    List<OrigemPagamentoDespesa>? origens,
    List<FormaDePagamento>? formasDePagamento,
    ModoLancamentoDespesa? modo,
    String? descricao,
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    int? formaPagamentoId,
    bool limparFormaPagamento = false,
    DateTime? dataPagamento,
    DateTime? dataInicial,
    bool? pulouPorFechamento,
    int? diaVencimento,
    int? parcelas,
    Despesa? despesaCriada,
    String? erro,
    LancarDespesaStep? step,
  }) {
    return LancarDespesaState(
      empresaId: empresaId ?? this.empresaId,
      caixaId: caixaId ?? this.caixaId,
      categorias: categorias ?? this.categorias,
      origens: origens ?? this.origens,
      formasDePagamento: formasDePagamento ?? this.formasDePagamento,
      modo: modo ?? this.modo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      categoriaId: categoriaId ?? this.categoriaId,
      origemPagamentoId: origemPagamentoId ?? this.origemPagamentoId,
      formaPagamentoId:
          limparFormaPagamento ? null : (formaPagamentoId ?? this.formaPagamentoId),
      dataPagamento: dataPagamento ?? this.dataPagamento,
      dataInicial: dataInicial ?? this.dataInicial,
      pulouPorFechamento: pulouPorFechamento ?? this.pulouPorFechamento,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      parcelas: parcelas ?? this.parcelas,
      despesaCriada: despesaCriada ?? this.despesaCriada,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        caixaId,
        categorias,
        origens,
        formasDePagamento,
        modo,
        descricao,
        valor,
        categoriaId,
        origemPagamentoId,
        formaPagamentoId,
        dataPagamento,
        dataInicial,
        pulouPorFechamento,
        diaVencimento,
        parcelas,
        despesaCriada,
        erro,
        step,
      ];
}

enum LancarDespesaStep {
  inicial,
  carregando,
  editando,
  salvando,
  criada,
  validacaoInvalida,
  falha,
}
