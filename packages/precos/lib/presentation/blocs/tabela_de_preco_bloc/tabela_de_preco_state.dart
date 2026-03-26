part of 'tabela_de_preco_bloc.dart';

enum TabelaDePrecoStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class TabelaDePrecoState extends Equatable {
  final TabelaDePrecoStep tabelaDePrecoStep;
  final String? nome;
  final int? id;
  final bool inativa;
  final double? terminador;

  const TabelaDePrecoState({
    required this.tabelaDePrecoStep,
    this.nome,
    this.id,
    this.inativa = false,
    this.terminador,
  });

  factory TabelaDePrecoState.fromModel(
    TabelaDePreco tabela, {
    TabelaDePrecoStep step = TabelaDePrecoStep.carregado,
  }) {
    return TabelaDePrecoState(
      tabelaDePrecoStep: step,
      nome: tabela.nome,
      id: tabela.id,
      inativa: tabela.inativa,
      terminador: tabela.terminador,
    );
  }

  TabelaDePrecoState copyWith({
    TabelaDePrecoStep? tabelaDePrecoStep,
    String? nome,
    int? id,
    bool? inativa,
    double? terminador,
  }) {
    return TabelaDePrecoState(
      tabelaDePrecoStep: tabelaDePrecoStep ?? this.tabelaDePrecoStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      inativa: inativa ?? this.inativa,
      terminador: terminador ?? this.terminador,
    );
  }

  @override
  List<Object?> get props => [tabelaDePrecoStep, nome, id, inativa, terminador];
}
