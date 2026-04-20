part of 'venda_bloc.dart';

enum VendaStep { configuracao, leitura }

enum VendaProcesso { finalizarVenda, criarPedido }

class VendaState extends Equatable {
  final VendaStep step;
  final SelectData? clienteSelecionado;
  final SelectData? vendedorSelecionado;
  final SelectData? tabelaDePrecoSelecionada;
  final String? erro;
  final bool processando;
  final VendaProcesso? processoAtual;
  final String? listaCompartilhadaHash;
  final int? pedidoCriadoId;

  const VendaState({
    this.step = VendaStep.configuracao,
    this.clienteSelecionado,
    this.vendedorSelecionado,
    this.tabelaDePrecoSelecionada,
    this.erro,
    this.processando = false,
    this.processoAtual,
    this.listaCompartilhadaHash,
    this.pedidoCriadoId,
  });

  bool get leituraIniciada => step == VendaStep.leitura;
  bool get podeIniciarLeitura =>
      clienteSelecionado != null &&
      vendedorSelecionado != null &&
      tabelaDePrecoSelecionada != null;
  int? get tabelaDePrecoId => tabelaDePrecoSelecionada?.id;

  VendaState copyWith({
    VendaStep? step,
    Object? clienteSelecionado = _sentinela,
    Object? vendedorSelecionado = _sentinela,
    Object? tabelaDePrecoSelecionada = _sentinela,
    Object? erro = _sentinela,
    bool? processando,
    Object? processoAtual = _sentinela,
    Object? listaCompartilhadaHash = _sentinela,
    Object? pedidoCriadoId = _sentinela,
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
      processoAtual: identical(processoAtual, _sentinela)
          ? this.processoAtual
          : processoAtual as VendaProcesso?,
      listaCompartilhadaHash: identical(listaCompartilhadaHash, _sentinela)
          ? this.listaCompartilhadaHash
          : listaCompartilhadaHash as String?,
      pedidoCriadoId: identical(pedidoCriadoId, _sentinela)
          ? this.pedidoCriadoId
          : pedidoCriadoId as int?,
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
        processoAtual,
        listaCompartilhadaHash,
        pedidoCriadoId,
      ];
}

const Object _sentinela = Object();
