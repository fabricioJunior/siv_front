part of 'cupom_bloc.dart';

class CupomState extends Equatable {
  final int? id;
  final String? codigo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TipoDesconto tipoDesconto;
  final double? valorPercentual;
  final double? valorDescontoMaximo;
  final double? valorFixo;
  final double? valorMinimoCompra;
  final int? quantidadeMinima;
  final double? precoFixo;
  final TipoEscopo tipoEscopo;
  final List<int>? referenciaIds;
  final List<ItemComboKit>? comboKit;
  final int? quantidadeLeva;
  final int? quantidadePaga;
  final int? limiteUsos;
  final bool ativa;
  final Cupom? cupom;
  final String? erro;
  final CupomStep step;

  const CupomState({
    this.id,
    this.codigo,
    this.dataInicio,
    this.dataFim,
    this.tipoDesconto = TipoDesconto.percentual,
    this.valorPercentual,
    this.valorDescontoMaximo,
    this.valorFixo,
    this.valorMinimoCompra,
    this.quantidadeMinima,
    this.precoFixo,
    this.tipoEscopo = TipoEscopo.geral,
    this.referenciaIds,
    this.comboKit,
    this.quantidadeLeva,
    this.quantidadePaga,
    this.limiteUsos,
    this.ativa = true,
    this.cupom,
    this.erro,
    required this.step,
  });

  CupomState.fromModel(Cupom origem, {CupomStep? step})
      : id = origem.id,
        codigo = origem.codigo,
        dataInicio = origem.dataInicio,
        dataFim = origem.dataFim,
        tipoDesconto = origem.tipoDesconto,
        valorPercentual = origem.valorPercentual,
        valorDescontoMaximo = origem.valorDescontoMaximo,
        valorFixo = origem.valorFixo,
        valorMinimoCompra = origem.valorMinimoCompra,
        quantidadeMinima = origem.quantidadeMinima,
        precoFixo = origem.precoFixo,
        tipoEscopo = origem.tipoEscopo,
        referenciaIds = origem.referenciaIds,
        comboKit = origem.comboKit,
        quantidadeLeva = origem.quantidadeLeva,
        quantidadePaga = origem.quantidadePaga,
        limiteUsos = origem.limiteUsos,
        ativa = origem.ativa,
        cupom = origem,
        erro = null,
        step = step ?? CupomStep.editando;

  CupomState copyWith({
    String? codigo,
    DateTime? dataInicio,
    DateTime? dataFim,
    TipoDesconto? tipoDesconto,
    double? valorPercentual,
    double? valorDescontoMaximo,
    double? valorFixo,
    double? valorMinimoCompra,
    int? quantidadeMinima,
    double? precoFixo,
    TipoEscopo? tipoEscopo,
    List<int>? referenciaIds,
    List<ItemComboKit>? comboKit,
    int? quantidadeLeva,
    int? quantidadePaga,
    bool limparEscopo = false,
    int? limiteUsos,
    bool? ativa,
    Cupom? cupom,
    String? erro,
    CupomStep? step,
  }) {
    return CupomState(
      id: id,
      codigo: codigo ?? this.codigo,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      tipoDesconto: tipoDesconto ?? this.tipoDesconto,
      valorPercentual: valorPercentual ?? this.valorPercentual,
      valorDescontoMaximo: valorDescontoMaximo ?? this.valorDescontoMaximo,
      valorFixo: valorFixo ?? this.valorFixo,
      valorMinimoCompra: valorMinimoCompra ?? this.valorMinimoCompra,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      precoFixo: precoFixo ?? this.precoFixo,
      tipoEscopo: tipoEscopo ?? this.tipoEscopo,
      referenciaIds: limparEscopo ? null : (referenciaIds ?? this.referenciaIds),
      comboKit: limparEscopo ? null : (comboKit ?? this.comboKit),
      quantidadeLeva: limparEscopo ? null : (quantidadeLeva ?? this.quantidadeLeva),
      quantidadePaga: limparEscopo ? null : (quantidadePaga ?? this.quantidadePaga),
      limiteUsos: limiteUsos ?? this.limiteUsos,
      ativa: ativa ?? this.ativa,
      cupom: cupom ?? this.cupom,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        dataInicio,
        dataFim,
        tipoDesconto,
        valorPercentual,
        valorDescontoMaximo,
        valorFixo,
        valorMinimoCompra,
        quantidadeMinima,
        precoFixo,
        tipoEscopo,
        referenciaIds,
        comboKit,
        quantidadeLeva,
        quantidadePaga,
        limiteUsos,
        ativa,
        cupom,
        erro,
        step,
      ];
}

enum CupomStep {
  inicial,
  carregando,
  editando,
  salvando,
  criado,
  salvo,
  validacaoInvalida,
  falha,
}
