part of 'entrada_manual_de_produtos_bloc.dart';

enum EntradaManualDeProdutosStep { configuracao, leitura }

class EntradaManualDeProdutosState extends Equatable {
  final EntradaManualDeProdutosStep step;
  final SelectData? funcionarioSelecionado;
  final SelectData? tabelaDePrecoSelecionada;
  final String? erro;
  final bool salvando;
  final bool verificandoCaixa;
  final String? listaCompartilhadaHash;
  final int versaoConfiguracao;

  const EntradaManualDeProdutosState({
    this.step = EntradaManualDeProdutosStep.configuracao,
    this.funcionarioSelecionado,
    this.tabelaDePrecoSelecionada,
    this.erro,
    this.salvando = false,
    this.verificandoCaixa = false,
    this.listaCompartilhadaHash,
    this.versaoConfiguracao = 0,
  });

  bool get leituraIniciada => step == EntradaManualDeProdutosStep.leitura;
  bool get podeIniciarLeitura =>
      funcionarioSelecionado != null && tabelaDePrecoSelecionada != null;
  int? get tabelaDePrecoId => tabelaDePrecoSelecionada?.id;

  EntradaManualDeProdutosState copyWith({
    EntradaManualDeProdutosStep? step,
    Object? funcionarioSelecionado = _sentinela,
    Object? tabelaDePrecoSelecionada = _sentinela,
    Object? erro = _sentinela,
    bool? salvando,
    bool? verificandoCaixa,
    Object? listaCompartilhadaHash = _sentinela,
    int? versaoConfiguracao,
  }) {
    return EntradaManualDeProdutosState(
      step: step ?? this.step,
      versaoConfiguracao: versaoConfiguracao ?? this.versaoConfiguracao,
      funcionarioSelecionado: identical(funcionarioSelecionado, _sentinela)
          ? this.funcionarioSelecionado
          : funcionarioSelecionado as SelectData?,
      tabelaDePrecoSelecionada: identical(tabelaDePrecoSelecionada, _sentinela)
          ? this.tabelaDePrecoSelecionada
          : tabelaDePrecoSelecionada as SelectData?,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      salvando: salvando ?? this.salvando,
      verificandoCaixa: verificandoCaixa ?? this.verificandoCaixa,
      listaCompartilhadaHash: identical(listaCompartilhadaHash, _sentinela)
          ? this.listaCompartilhadaHash
          : listaCompartilhadaHash as String?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    funcionarioSelecionado,
    tabelaDePrecoSelecionada,
    erro,
    salvando,
    verificandoCaixa,
    listaCompartilhadaHash,
    versaoConfiguracao,
  ];
}

const Object _sentinela = Object();
