part of 'romaneios_entrada_manual_bloc.dart';

class RomaneiosEntradaManualState extends Equatable {
  final List<Romaneio> romaneios;
  final String searchTerm;
  final DateTime? dataHoraInicial;
  final DateTime? dataHoraFinal;
  final List<int> referenciaIds;
  final String? erro;
  final RomaneiosEntradaManualStep step;

  const RomaneiosEntradaManualState({
    required this.romaneios,
    this.searchTerm = '',
    this.dataHoraInicial,
    this.dataHoraFinal,
    this.referenciaIds = const [],
    required this.step,
    this.erro,
  });

  const RomaneiosEntradaManualState.initial()
      : romaneios = const [],
        searchTerm = '',
        dataHoraInicial = null,
        dataHoraFinal = null,
        referenciaIds = const [],
        erro = null,
        step = RomaneiosEntradaManualStep.inicial;

  RomaneiosEntradaManualState copyWith({
    List<Romaneio>? romaneios,
    String? searchTerm,
    DateTime? dataHoraInicial,
    bool limparDataHoraInicial = false,
    DateTime? dataHoraFinal,
    bool limparDataHoraFinal = false,
    List<int>? referenciaIds,
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
      referenciaIds: referenciaIds ?? this.referenciaIds,
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
        referenciaIds,
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
