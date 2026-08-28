part of 'estampa_bloc.dart';

class EstampaState extends Equatable {
  final int? id;
  final String? nome;
  final bool? inativo;
  final EstampaStep estampaStep;
  final Estampa? estampa;

  const EstampaState({
    this.id,
    this.nome,
    this.inativo,
    this.estampa,
    required this.estampaStep,
  });

  EstampaState.fromModel(this.estampa, {EstampaStep? step})
    : id = estampa!.id,
      nome = estampa.nome,
      inativo = estampa.inativo,
      estampaStep = step ?? EstampaStep.carregado;

  EstampaState copyWith({
    int? id,
    String? nome,
    bool? inativo,
    EstampaStep? estampaStep,
    Estampa? estampa,
  }) {
    return EstampaState(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
      estampaStep: estampaStep ?? this.estampaStep,
      estampa: estampa ?? this.estampa,
    );
  }

  @override
  List<Object?> get props => [id, nome, inativo, estampaStep];
}

enum EstampaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}
