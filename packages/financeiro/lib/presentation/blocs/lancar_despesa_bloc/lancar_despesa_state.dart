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
    this.diaVencimento,
    this.parcelas,
    this.despesaCriada,
    this.erro,
    required this.step,
  });

  /// Preview exibido no modo parcelado (ex: "7x de R$300,00 a partir de 09/2026").
  String? get previewParcelamento {
    if (modo != ModoLancamentoDespesa.parcelada) return null;
    final total = parcelas;
    final valorParcela = valor;
    if (total == null || total <= 1 || valorParcela == null) return null;
    final agora = DateTime.now();
    return '${total}x de R\$${valorParcela.toStringAsFixed(2)} a partir de '
        '${agora.month.toString().padLeft(2, '0')}/${agora.year}';
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
