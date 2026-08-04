part of 'romaneios_entrada_manual_bloc.dart';

abstract class RomaneiosEntradaManualEvent {}

class RomaneiosEntradaManualIniciou extends RomaneiosEntradaManualEvent {
  final String? searchTerm;
  final DateTime? dataHoraInicial;
  final bool dataHoraInicialInformada;
  final DateTime? dataHoraFinal;
  final bool dataHoraFinalInformada;
  final List<int>? referenciaIds;
  final bool referenciaIdsInformada;

  RomaneiosEntradaManualIniciou({
    this.searchTerm,
    this.dataHoraInicial,
    this.dataHoraInicialInformada = false,
    this.dataHoraFinal,
    this.dataHoraFinalInformada = false,
    this.referenciaIds,
    this.referenciaIdsInformada = false,
  });
}
