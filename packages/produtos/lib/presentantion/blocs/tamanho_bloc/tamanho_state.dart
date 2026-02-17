part of 'tamanho_bloc.dart';

class TamanhoState extends Equatable {
  final int? id;
  final String? nome;
  final bool? inativo;
  final TamanhoStep tamanhoStep;
  final Tamanho? tamanho;

  const TamanhoState({
    this.id,
    this.nome,
    this.inativo,
    this.tamanho,
    required this.tamanhoStep,
  });

  TamanhoState.fromModel(this.tamanho, {TamanhoStep? step})
    : id = tamanho!.id,
      nome = tamanho.nome,
      inativo = tamanho.inativo,
      tamanhoStep = step ?? TamanhoStep.carregado;

  TamanhoState copyWith({
    int? id,
    String? nome,
    bool? inativo,
    TamanhoStep? tamanhoStep,
    Tamanho? tamanho,
  }) {
    return TamanhoState(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
      tamanhoStep: tamanhoStep ?? this.tamanhoStep,
      tamanho: tamanho ?? this.tamanho,
    );
  }

  @override
  List<Object?> get props => [id, nome, inativo, tamanhoStep];
}

enum TamanhoStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}
