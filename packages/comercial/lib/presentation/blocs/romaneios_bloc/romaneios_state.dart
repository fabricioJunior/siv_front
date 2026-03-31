part of 'romaneios_bloc.dart';

class RomaneiosState extends Equatable {
  final List<Romaneio> romaneios;
  final String? erro;
  final RomaneiosStep step;

  const RomaneiosState({
    required this.romaneios,
    required this.step,
    this.erro,
  });

  const RomaneiosState.initial()
      : romaneios = const [],
        erro = null,
        step = RomaneiosStep.inicial;

  RomaneiosState copyWith({
    List<Romaneio>? romaneios,
    String? erro,
    RomaneiosStep? step,
  }) {
    return RomaneiosState(
      romaneios: romaneios ?? this.romaneios,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [romaneios, erro, step];
}

enum RomaneiosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
