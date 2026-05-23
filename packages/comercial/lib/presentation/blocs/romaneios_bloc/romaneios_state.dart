part of 'romaneios_bloc.dart';

class RomaneiosState extends Equatable {
  final List<Romaneio> romaneios;
  final Map<int, int> itensPendentesPorRomaneio;
  final String searchTerm;
  final String? erro;
  final RomaneiosStep step;

  const RomaneiosState({
    required this.romaneios,
    this.itensPendentesPorRomaneio = const {},
    this.searchTerm = '',
    required this.step,
    this.erro,
  });

  const RomaneiosState.initial()
      : romaneios = const [],
        itensPendentesPorRomaneio = const {},
        searchTerm = '',
        erro = null,
        step = RomaneiosStep.inicial;

  RomaneiosState copyWith({
    List<Romaneio>? romaneios,
    Map<int, int>? itensPendentesPorRomaneio,
    String? searchTerm,
    String? erro,
    RomaneiosStep? step,
  }) {
    return RomaneiosState(
      romaneios: romaneios ?? this.romaneios,
      itensPendentesPorRomaneio:
          itensPendentesPorRomaneio ?? this.itensPendentesPorRomaneio,
      searchTerm: searchTerm ?? this.searchTerm,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        romaneios,
        itensPendentesPorRomaneio,
        searchTerm,
        erro,
        step,
      ];
}

enum RomaneiosStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
