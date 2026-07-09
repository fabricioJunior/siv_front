part of 'venda_bloc.dart';

enum VendaStep { configuracao, leitura }

enum VendaProcesso { finalizarVenda, criarPedido, salvarOrcamento }

class VendaState extends Equatable {
  final VendaStep step;
  final SelectData? clienteSelecionado;
  final SelectData? vendedorSelecionado;
  final SelectData? tabelaDePrecoSelecionada;
  final String? erro;
  final bool processando;
  final bool verificandoCaixa;
  final VendaProcesso? processoAtual;
  final String? listaCompartilhadaHash;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final double valorDesconto;
  final List<Map<String, dynamic>> descontosItens;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final int? pedidoCriadoId;
  final String? orcamentoId;
  final List<ProdutoCompartilhado> orcamentoItensPreCarregados;
  final int orcamentoSalvoContador;

  const VendaState({
    this.step = VendaStep.configuracao,
    this.clienteSelecionado,
    this.vendedorSelecionado,
    this.tabelaDePrecoSelecionada,
    this.erro,
    this.processando = false,
    this.verificandoCaixa = false,
    this.processoAtual,
    this.listaCompartilhadaHash,
    this.formasDePagamentoRealizadas = const [],
    this.valorDesconto = 0,
    this.descontosItens = const [],
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pedidoCriadoId,
    this.orcamentoId,
    this.orcamentoItensPreCarregados = const [],
    this.orcamentoSalvoContador = 0,
  });

  bool get leituraIniciada => step == VendaStep.leitura;
  bool get podeIniciarLeitura =>
      !verificandoCaixa &&
      clienteSelecionado != null &&
      vendedorSelecionado != null &&
      tabelaDePrecoSelecionada != null;
  int? get tabelaDePrecoId => tabelaDePrecoSelecionada?.id;
  /// Indica que a leitura de produtos ainda não foi iniciada (usuário ainda
  /// não apertou "Iniciar venda"). Não depende de cliente/vendedor/tabela já
  /// estarem preenchidos, pois a tabela de preço pode vir pré-selecionada
  /// automaticamente (ver TabelasDePrecoSeletor).
  bool get estadoInicial => !leituraIniciada;

  VendaState copyWith({
    VendaStep? step,
    Object? clienteSelecionado = _sentinela,
    Object? vendedorSelecionado = _sentinela,
    Object? tabelaDePrecoSelecionada = _sentinela,
    Object? erro = _sentinela,
    bool? processando,
    bool? verificandoCaixa,
    Object? processoAtual = _sentinela,
    Object? listaCompartilhadaHash = _sentinela,
    Object? formasDePagamentoRealizadas = _sentinela,
    double? valorDesconto,
    List<Map<String, dynamic>>? descontosItens,
    bool? incluirCpfNaNota,
    String? cpfNaNota,
    Object? pedidoCriadoId = _sentinela,
    Object? orcamentoId = _sentinela,
    List<ProdutoCompartilhado>? orcamentoItensPreCarregados,
    int? orcamentoSalvoContador,
  }) {
    return VendaState(
      step: step ?? this.step,
      clienteSelecionado: identical(clienteSelecionado, _sentinela)
          ? this.clienteSelecionado
          : clienteSelecionado as SelectData?,
      vendedorSelecionado: identical(vendedorSelecionado, _sentinela)
          ? this.vendedorSelecionado
          : vendedorSelecionado as SelectData?,
      tabelaDePrecoSelecionada: identical(tabelaDePrecoSelecionada, _sentinela)
          ? this.tabelaDePrecoSelecionada
          : tabelaDePrecoSelecionada as SelectData?,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      processando: processando ?? this.processando,
      verificandoCaixa: verificandoCaixa ?? this.verificandoCaixa,
      processoAtual: identical(processoAtual, _sentinela)
          ? this.processoAtual
          : processoAtual as VendaProcesso?,
      listaCompartilhadaHash: identical(listaCompartilhadaHash, _sentinela)
          ? this.listaCompartilhadaHash
          : listaCompartilhadaHash as String?,
      formasDePagamentoRealizadas:
          identical(formasDePagamentoRealizadas, _sentinela)
              ? this.formasDePagamentoRealizadas
              : formasDePagamentoRealizadas as List<Map<String, dynamic>>,
      valorDesconto: valorDesconto ?? this.valorDesconto,
      descontosItens: descontosItens ?? this.descontosItens,
      incluirCpfNaNota: incluirCpfNaNota ?? this.incluirCpfNaNota,
      cpfNaNota: cpfNaNota ?? this.cpfNaNota,
      pedidoCriadoId: identical(pedidoCriadoId, _sentinela)
          ? this.pedidoCriadoId
          : pedidoCriadoId as int?,
      orcamentoId: identical(orcamentoId, _sentinela)
          ? this.orcamentoId
          : orcamentoId as String?,
      orcamentoItensPreCarregados:
          orcamentoItensPreCarregados ?? this.orcamentoItensPreCarregados,
      orcamentoSalvoContador:
          orcamentoSalvoContador ?? this.orcamentoSalvoContador,
    );
  }

  @override
  List<Object?> get props => [
        step,
        clienteSelecionado,
        vendedorSelecionado,
        tabelaDePrecoSelecionada,
        erro,
        processando,
        verificandoCaixa,
        processoAtual,
        listaCompartilhadaHash,
        formasDePagamentoRealizadas,
        valorDesconto,
        descontosItens,
        incluirCpfNaNota,
        cpfNaNota,
        pedidoCriadoId,
        orcamentoId,
        orcamentoItensPreCarregados,
        orcamentoSalvoContador,
      ];
}

const Object _sentinela = Object();
