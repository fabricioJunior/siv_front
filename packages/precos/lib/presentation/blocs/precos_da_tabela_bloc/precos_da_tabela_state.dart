part of 'precos_da_tabela_bloc.dart';

enum PrecosDaTabelaStep { inicial, carregando, carregado, salvando, falha }

class PrecosDaTabelaState extends Equatable {
  final PrecosDaTabelaStep step;
  final int? tabelaDePrecoId;
  final List<PrecoDaReferencia> precos;
  final String? erro;

  const PrecosDaTabelaState({
    required this.step,
    this.tabelaDePrecoId,
    this.precos = const [],
    this.erro,
  });

  PrecosDaTabelaState copyWith({
    PrecosDaTabelaStep? step,
    int? tabelaDePrecoId,
    List<PrecoDaReferencia>? precos,
    String? erro,
    bool clearErro = false,
  }) {
    return PrecosDaTabelaState(
      step: step ?? this.step,
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      precos: precos ?? this.precos,
      erro: clearErro ? null : (erro ?? this.erro),
    );
  }

  @override
  List<Object?> get props => [step, tabelaDePrecoId, precos, erro];
}
