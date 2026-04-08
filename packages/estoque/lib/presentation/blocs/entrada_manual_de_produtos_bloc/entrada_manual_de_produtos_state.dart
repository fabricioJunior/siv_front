part of 'entrada_manual_de_produtos_bloc.dart';

enum EntradaManualDeProdutosStep { configuracao, leitura }

class EntradaManualDeProdutosState extends Equatable {
  final EntradaManualDeProdutosStep step;
  final SelectData? funcionarioSelecionado;
  final SelectData? tabelaDePrecoSelecionada;
  final String? erro;

  const EntradaManualDeProdutosState({
    this.step = EntradaManualDeProdutosStep.configuracao,
    this.funcionarioSelecionado,
    this.tabelaDePrecoSelecionada,
    this.erro,
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
  }) {
    return EntradaManualDeProdutosState(
      step: step ?? this.step,
      funcionarioSelecionado: identical(funcionarioSelecionado, _sentinela)
          ? this.funcionarioSelecionado
          : funcionarioSelecionado as SelectData?,
      tabelaDePrecoSelecionada: identical(tabelaDePrecoSelecionada, _sentinela)
          ? this.tabelaDePrecoSelecionada
          : tabelaDePrecoSelecionada as SelectData?,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    funcionarioSelecionado,
    tabelaDePrecoSelecionada,
    erro,
  ];
}

const Object _sentinela = Object();
