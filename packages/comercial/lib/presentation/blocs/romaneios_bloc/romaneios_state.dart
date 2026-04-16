part of 'romaneios_bloc.dart';

class RomaneiosState extends Equatable {
  final List<Romaneio> romaneios;
  final Map<int, int> itensPendentesPorRomaneio;
  final String? erro;
  final RomaneiosStep step;

  const RomaneiosState({
    required this.romaneios,
    this.itensPendentesPorRomaneio = const {},
    required this.step,
    this.erro,
  });

  const RomaneiosState.initial()
      : romaneios = const [],
        itensPendentesPorRomaneio = const {},
        erro = null,
        step = RomaneiosStep.inicial;

  RomaneiosState copyWith({
    List<Romaneio>? romaneios,
    Map<int, int>? itensPendentesPorRomaneio,
    String? erro,
    RomaneiosStep? step,
  }) {
    return RomaneiosState(
      romaneios: romaneios ?? this.romaneios,
      itensPendentesPorRomaneio:
          itensPendentesPorRomaneio ?? this.itensPendentesPorRomaneio,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [romaneios, itensPendentesPorRomaneio, erro, step];
}

enum RomaneiosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
