part of 'pedido_bloc.dart';

class PedidoState extends Equatable {
  final int? id;
  final String? pessoaId;
  final String? funcionarioId;
  final String? tabelaPrecoId;
  final String? parcelas;
  final String? intervalo;
  final String? dataBasePagamento;
  final String? previsaoDeFaturamento;
  final String? previsaoDeEntrega;
  final String? tipo;
  final bool? fiscal;
  final String? observacao;
  final Pedido? pedido;
  final String? erro;
  final PedidoStep step;

  const PedidoState({
    this.id,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.parcelas,
    this.intervalo,
    this.dataBasePagamento,
    this.previsaoDeFaturamento,
    this.previsaoDeEntrega,
    this.tipo,
    this.fiscal,
    this.observacao,
    this.pedido,
    this.erro,
    required this.step,
  });

  const PedidoState.initial()
      : id = null,
        pessoaId = '',
        funcionarioId = '',
        tabelaPrecoId = '',
        parcelas = '1',
        intervalo = '30',
        dataBasePagamento = '',
        previsaoDeFaturamento = '',
        previsaoDeEntrega = '',
        tipo = 'venda',
        fiscal = false,
        observacao = '',
        pedido = null,
        erro = null,
        step = PedidoStep.inicial;

  PedidoState.fromModel(
    Pedido model, {
    PedidoStep? step,
  })  : id = model.id,
        pessoaId = (model.pessoaId ?? '').toString(),
        funcionarioId = (model.funcionarioId ?? '').toString(),
        tabelaPrecoId = (model.tabelaPrecoId ?? '').toString(),
        parcelas = (model.parcelas ?? 1).toString(),
        intervalo = (model.intervalo ?? 30).toString(),
        dataBasePagamento = _dateOnly(model.dataBasePagamento),
        previsaoDeFaturamento = _dateOnly(model.previsaoDeFaturamento),
        previsaoDeEntrega = _dateOnly(model.previsaoDeEntrega),
        tipo = model.tipo ?? 'venda',
        fiscal = model.fiscal ?? false,
        observacao = model.observacao ?? '',
        pedido = model,
        erro = null,
        step = step ?? PedidoStep.editando;

  PedidoState copyWith({
    int? id,
    String? pessoaId,
    String? funcionarioId,
    String? tabelaPrecoId,
    String? parcelas,
    String? intervalo,
    String? dataBasePagamento,
    String? previsaoDeFaturamento,
    String? previsaoDeEntrega,
    String? tipo,
    bool? fiscal,
    String? observacao,
    Pedido? pedido,
    String? erro,
    PedidoStep? step,
  }) {
    return PedidoState(
      id: id ?? this.id,
      pessoaId: pessoaId ?? this.pessoaId,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      tabelaPrecoId: tabelaPrecoId ?? this.tabelaPrecoId,
      parcelas: parcelas ?? this.parcelas,
      intervalo: intervalo ?? this.intervalo,
      dataBasePagamento: dataBasePagamento ?? this.dataBasePagamento,
      previsaoDeFaturamento:
          previsaoDeFaturamento ?? this.previsaoDeFaturamento,
      previsaoDeEntrega: previsaoDeEntrega ?? this.previsaoDeEntrega,
      tipo: tipo ?? this.tipo,
      fiscal: fiscal ?? this.fiscal,
      observacao: observacao ?? this.observacao,
      pedido: pedido ?? this.pedido,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        parcelas,
        intervalo,
        dataBasePagamento,
        previsaoDeFaturamento,
        previsaoDeEntrega,
        tipo,
        fiscal,
        observacao,
        pedido,
        erro,
        step,
      ];

  static String _dateOnly(DateTime? value) {
    if (value == null) return '';
    return value.toIso8601String().split('T').first;
  }
}

enum PedidoStep {
  inicial,
  carregando,
  editando,
  salvando,
  processando,
  criado,
  salvo,
  conferido,
  faturado,
  cancelado,
  validacaoInvalida,
  falha,
}
