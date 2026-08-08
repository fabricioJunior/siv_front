part of 'promocao_bloc.dart';

class PromocaoState extends Equatable {
  final int? id;
  final String? nome;
  final String? descricao;
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
  final int? limiteUnidadesVendidas;
  final bool somenteAniversariante;
  final bool ativa;
  final bool restringirFormasPagamento;
  final List<PromocaoFormaPagamento> formasPagamento;
  final List<FormaDePagamento> formasDePagamentoDisponiveis;
  final Promocao? promocao;
  final String? erro;
  final PromocaoStep step;

  const PromocaoState({
    this.id,
    this.nome,
    this.descricao,
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
    this.limiteUnidadesVendidas,
    this.somenteAniversariante = false,
    this.ativa = true,
    this.restringirFormasPagamento = false,
    this.formasPagamento = const [],
    this.formasDePagamentoDisponiveis = const [],
    this.promocao,
    this.erro,
    required this.step,
  });

  PromocaoState.fromModel(
    Promocao origem, {
    PromocaoStep? step,
    this.formasDePagamentoDisponiveis = const [],
  })  : id = origem.id,
        nome = origem.nome,
        descricao = origem.descricao,
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
        limiteUnidadesVendidas = origem.limiteUnidadesVendidas,
        somenteAniversariante = origem.somenteAniversariante,
        ativa = origem.ativa,
        restringirFormasPagamento = origem.restringirFormasPagamento,
        formasPagamento = origem.formasPagamento,
        promocao = origem,
        erro = null,
        step = step ?? PromocaoStep.editando;

  PromocaoState copyWith({
    String? nome,
    String? descricao,
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
    int? limiteUnidadesVendidas,
    bool? somenteAniversariante,
    bool? ativa,
    bool? restringirFormasPagamento,
    List<PromocaoFormaPagamento>? formasPagamento,
    List<FormaDePagamento>? formasDePagamentoDisponiveis,
    Promocao? promocao,
    String? erro,
    PromocaoStep? step,
  }) {
    return PromocaoState(
      id: id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
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
      limiteUnidadesVendidas:
          limiteUnidadesVendidas ?? this.limiteUnidadesVendidas,
      somenteAniversariante: somenteAniversariante ?? this.somenteAniversariante,
      ativa: ativa ?? this.ativa,
      restringirFormasPagamento:
          restringirFormasPagamento ?? this.restringirFormasPagamento,
      formasPagamento: formasPagamento ?? this.formasPagamento,
      formasDePagamentoDisponiveis:
          formasDePagamentoDisponiveis ?? this.formasDePagamentoDisponiveis,
      promocao: promocao ?? this.promocao,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
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
        limiteUnidadesVendidas,
        somenteAniversariante,
        ativa,
        restringirFormasPagamento,
        formasPagamento,
        formasDePagamentoDisponiveis,
        promocao,
        erro,
        step,
      ];
}

enum PromocaoStep {
  inicial,
  carregando,
  editando,
  salvando,
  criado,
  salvo,
  validacaoInvalida,
  falha,
}
