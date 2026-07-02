part of 'romaneios_entrada_manual_bloc.dart';

class RomaneiosEntradaManualState extends Equatable {
  final List<Romaneio> romaneios;
  final String searchTerm;
  final DateTime? dataHoraInicial;
  final DateTime? dataHoraFinal;
  final String? erro;
  final RomaneiosEntradaManualStep step;

  const RomaneiosEntradaManualState({
    required this.romaneios,
    this.searchTerm = '',
    this.dataHoraInicial,
    this.dataHoraFinal,
    required this.step,
    this.erro,
  });

  const RomaneiosEntradaManualState.initial()
      : romaneios = const [],
        searchTerm = '',
        dataHoraInicial = null,
        dataHoraFinal = null,
        erro = null,
        step = RomaneiosEntradaManualStep.inicial;

  RomaneiosEntradaManualState copyWith({
    List<Romaneio>? romaneios,
    String? searchTerm,
    DateTime? dataHoraInicial,
    bool limparDataHoraInicial = false,
    DateTime? dataHoraFinal,
    bool limparDataHoraFinal = false,
    String? erro,
    RomaneiosEntradaManualStep? step,
  }) {
    return RomaneiosEntradaManualState(
      romaneios: romaneios ?? this.romaneios,
      searchTerm: searchTerm ?? this.searchTerm,
      dataHoraInicial: limparDataHoraInicial
          ? null
          : (dataHoraInicial ?? this.dataHoraInicial),
      dataHoraFinal:
          limparDataHoraFinal ? null : (dataHoraFinal ?? this.dataHoraFinal),
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        romaneios,
        searchTerm,
        dataHoraInicial,
        dataHoraFinal,
        erro,
        step,
      ];
}

enum RomaneiosEntradaManualStep {
  inicial,
  carregando,
  sucesso,
  falha,
}
