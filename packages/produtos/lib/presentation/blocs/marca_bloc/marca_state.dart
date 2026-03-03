part of 'marca_bloc.dart';

enum MarcaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class MarcaState extends Equatable {
  final MarcaStep marcaStep;
  final String? nome;
  final int? id;
  final bool inativa;

  const MarcaState({
    required this.marcaStep,
    this.nome,
    this.id,
    this.inativa = false,
  });

  factory MarcaState.fromModel(
    Marca marca, {
    MarcaStep step = MarcaStep.carregado,
  }) {
    return MarcaState(
      marcaStep: step,
      nome: marca.nome,
      id: marca.id,
      inativa: marca.inativa,
    );
  }

  MarcaState copyWith({
    MarcaStep? marcaStep,
    String? nome,
    int? id,
    bool? inativa,
  }) {
    return MarcaState(
      marcaStep: marcaStep ?? this.marcaStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [marcaStep, nome, id, inativa];
}
