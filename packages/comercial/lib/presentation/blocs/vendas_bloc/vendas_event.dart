part of 'vendas_bloc.dart';

abstract class VendasEvent {}

class VendasIniciou extends VendasEvent {
  final String? searchTerm;
  final int? caixaId;
  final bool caixaIdInformado;
  final DateTime? dataHoraInicial;
  final bool dataHoraInicialInformada;
  final DateTime? dataHoraFinal;
  final bool dataHoraFinalInformada;

  VendasIniciou({
    this.searchTerm,
    this.caixaId,
    this.caixaIdInformado = false,
    this.dataHoraInicial,
    this.dataHoraInicialInformada = false,
    this.dataHoraFinal,
    this.dataHoraFinalInformada = false,
  });
}
