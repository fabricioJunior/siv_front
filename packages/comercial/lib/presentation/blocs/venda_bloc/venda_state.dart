part of 'venda_bloc.dart';

enum VendaStep { configuracao, leitura, pagamento }

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
  final double valorTaxaEntrega;
  final List<Map<String, dynamic>> descontosItens;
  final List<Map<String, dynamic>> descontosPromocao;
  final List<Map<String, dynamic>>? cupons;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;
  final Map<String, dynamic>? resgatePontos;
  final bool enviarNotaPorEmail;
  final String emailNota;
  final int? pedidoCriadoId;
  final String? orcamentoId;
  final List<ProdutoCompartilhado> orcamentoItensPreCarregados;
  final int orcamentoSalvoContador;
  final bool exigeClienteNaVenda;
  // Desconto digitado na leitura (F4); semeia o desconto da etapa de pagamento.
  final double descontoRascunho;
  final String? erroDesconto;
  final int descontoContador;
  // Sobe a cada confirmação do pagamento, mesmo com a mesma lista (retry).
  final int finalizacaoContador;
  final String? avisoNota;

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
    this.valorTaxaEntrega = 0,
    this.descontosItens = const [],
    this.descontosPromocao = const [],
    this.cupons,
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
    this.resgatePontos,
    this.enviarNotaPorEmail = false,
    this.emailNota = '',
    this.pedidoCriadoId,
    this.orcamentoId,
    this.orcamentoItensPreCarregados = const [],
    this.orcamentoSalvoContador = 0,
    this.exigeClienteNaVenda = false,
    this.descontoRascunho = 0,
    this.erroDesconto,
    this.descontoContador = 0,
    this.finalizacaoContador = 0,
    this.avisoNota,
  });

  bool get leituraIniciada => step != VendaStep.configuracao;
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
    double? valorTaxaEntrega,
    List<Map<String, dynamic>>? descontosItens,
    List<Map<String, dynamic>>? descontosPromocao,
    Object? cupons = _sentinela,
    bool? incluirCpfNaNota,
    String? cpfNaNota,
    bool? pontuarFidelidade,
    Object? resgatePontos = _sentinela,
    bool? enviarNotaPorEmail,
    String? emailNota,
    Object? pedidoCriadoId = _sentinela,
    Object? orcamentoId = _sentinela,
    List<ProdutoCompartilhado>? orcamentoItensPreCarregados,
    int? orcamentoSalvoContador,
    bool? exigeClienteNaVenda,
    double? descontoRascunho,
    Object? erroDesconto = _sentinela,
    int? descontoContador,
    int? finalizacaoContador,
    Object? avisoNota = _sentinela,
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
      valorTaxaEntrega: valorTaxaEntrega ?? this.valorTaxaEntrega,
      descontosItens: descontosItens ?? this.descontosItens,
      descontosPromocao: descontosPromocao ?? this.descontosPromocao,
      cupons: identical(cupons, _sentinela)
          ? this.cupons
          : cupons as List<Map<String, dynamic>>?,
      incluirCpfNaNota: incluirCpfNaNota ?? this.incluirCpfNaNota,
      cpfNaNota: cpfNaNota ?? this.cpfNaNota,
      pontuarFidelidade: pontuarFidelidade ?? this.pontuarFidelidade,
      resgatePontos: identical(resgatePontos, _sentinela)
          ? this.resgatePontos
          : resgatePontos as Map<String, dynamic>?,
      enviarNotaPorEmail: enviarNotaPorEmail ?? this.enviarNotaPorEmail,
      emailNota: emailNota ?? this.emailNota,
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
      exigeClienteNaVenda: exigeClienteNaVenda ?? this.exigeClienteNaVenda,
      descontoRascunho: descontoRascunho ?? this.descontoRascunho,
      erroDesconto: identical(erroDesconto, _sentinela)
          ? this.erroDesconto
          : erroDesconto as String?,
      descontoContador: descontoContador ?? this.descontoContador,
      finalizacaoContador: finalizacaoContador ?? this.finalizacaoContador,
      avisoNota:
          identical(avisoNota, _sentinela) ? this.avisoNota : avisoNota as String?,
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
        valorTaxaEntrega,
        descontosItens,
        descontosPromocao,
        cupons,
        incluirCpfNaNota,
        cpfNaNota,
        pontuarFidelidade,
        resgatePontos,
        enviarNotaPorEmail,
        emailNota,
        pedidoCriadoId,
        orcamentoId,
        orcamentoItensPreCarregados,
        orcamentoSalvoContador,
        exigeClienteNaVenda,
        descontoRascunho,
        erroDesconto,
        descontoContador,
        finalizacaoContador,
        avisoNota,
      ];
}

const Object _sentinela = Object();
