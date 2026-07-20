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
  final String modalidadeEntrega;
  final int? enderecoEntregaId;
  final Pedido? pedido;
  final List<PedidoPagamento> pagamentos;
  final List<PedidoEvento> eventos;
  final List<PedidoItem> itens;
  final int? pedidoTaxaEntregaCriadoId;
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
    this.modalidadeEntrega = 'retirada',
    this.enderecoEntregaId,
    this.pedido,
    this.pagamentos = const [],
    this.eventos = const [],
    this.itens = const [],
    this.pedidoTaxaEntregaCriadoId,
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
        modalidadeEntrega = 'retirada',
        enderecoEntregaId = null,
        pedido = null,
        pagamentos = const [],
        eventos = const [],
        itens = const [],
        pedidoTaxaEntregaCriadoId = null,
        erro = null,
        step = PedidoStep.inicial;

  PedidoState.fromModel(
    Pedido model, {
    PedidoStep? step,
    List<PedidoPagamento>? pagamentos,
    List<PedidoEvento>? eventos,
    List<PedidoItem>? itens,
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
        modalidadeEntrega = model.modalidadeEntrega ?? 'retirada',
        enderecoEntregaId = model.enderecoEntregaId,
        pedido = model,
        pagamentos = pagamentos ?? const [],
        eventos = eventos ?? const [],
        itens = itens ?? const [],
        pedidoTaxaEntregaCriadoId = null,
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
    String? modalidadeEntrega,
    int? enderecoEntregaId,
    bool limparEnderecoEntregaId = false,
    Pedido? pedido,
    List<PedidoPagamento>? pagamentos,
    List<PedidoEvento>? eventos,
    List<PedidoItem>? itens,
    int? pedidoTaxaEntregaCriadoId,
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
      modalidadeEntrega: modalidadeEntrega ?? this.modalidadeEntrega,
      enderecoEntregaId: limparEnderecoEntregaId
          ? null
          : (enderecoEntregaId ?? this.enderecoEntregaId),
      pedido: pedido ?? this.pedido,
      pagamentos: pagamentos ?? this.pagamentos,
      eventos: eventos ?? this.eventos,
      itens: itens ?? this.itens,
      pedidoTaxaEntregaCriadoId:
          pedidoTaxaEntregaCriadoId ?? this.pedidoTaxaEntregaCriadoId,
      erro: erro,
      step: step ?? this.step,
    );
  }

  bool get podeFechar {
    final situacaoPagamento = pedido?.situacaoPagamento;
    final situacaoEntrega = pedido?.situacaoEntrega;
    final pagamentoOk = situacaoPagamento == 'pago';
    final entregaOk = modalidadeEntrega == 'retirada' ||
        situacaoEntrega == 'entregue' ||
        situacaoEntrega == null;
    return pagamentoOk && entregaOk;
  }

  double get valorTotalItens {
    return itens.fold<double>(0, (total, item) {
      final unitario = item.valorUnitario ?? 0;
      final desconto = item.valorUnitDesconto ?? 0;
      final solicitado = item.solicitado ?? 0;
      return total + ((unitario - desconto) * solicitado);
    });
  }

  String get motivoNaoPodeFechar {
    final pendencias = <String>[];
    if (pedido?.situacaoPagamento != 'pago') {
      pendencias.add('pagamento pendente');
    }
    if (modalidadeEntrega == 'entrega' &&
        pedido?.situacaoEntrega != 'entregue' &&
        pedido?.situacaoEntrega != null) {
      pendencias.add('entrega não confirmada');
    }
    if (pendencias.isEmpty) return '';
    return 'Pendências: ${pendencias.join(', ')}.';
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
        modalidadeEntrega,
        enderecoEntregaId,
        pedido,
        pagamentos,
        eventos,
        itens,
        pedidoTaxaEntregaCriadoId,
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
  pagamentoAdicionado,
  pagamentoConfirmado,
  entregadorChamado,
  entregaConfirmada,
  taxaEntregaCriada,
  itemAdicionado,
  itemRemovido,
  itemConferido,
  validacaoInvalida,
  falha,
}
