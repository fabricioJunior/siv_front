part of 'cor_bloc.dart';

enum CorStep { inicial, carregando, carregado, editando, salvo, criado, falha }

class CorState extends Equatable {
  final CorStep corStep;
  final String? nome;
  final int? id;
  final bool inativo;

  const CorState({
    required this.corStep,
    this.nome,
    this.id,
    this.inativo = false,
  });

  factory CorState.fromModel(Cor cor, {CorStep step = CorStep.carregado}) {
    return CorState(
      corStep: step,
      nome: cor.nome,
      id: cor.id,
      inativo: cor.inativo ?? false,
    );
  }

  CorState copyWith({CorStep? corStep, String? nome, int? id, bool? inativo}) {
    return CorState(
      corStep: corStep ?? this.corStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      inativo: inativo ?? this.inativo,
    );
  }

  @override
  List<Object?> get props => [corStep, nome, id, inativo];
}
