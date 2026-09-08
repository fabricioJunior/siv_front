part of 'referencias_pendentes_peso_bloc.dart';

abstract class ReferenciasPendentesPesoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciasPendentesPesoIniciou extends ReferenciasPendentesPesoEvent {}

class ReferenciasPendentesPesoBuscou extends ReferenciasPendentesPesoEvent {
  final String? search;
  final String? orderBy;
  final String? orderDir;

  ReferenciasPendentesPesoBuscou({this.search, this.orderBy, this.orderDir});

  @override
  List<Object?> get props => [search, orderBy, orderDir];
}

class ReferenciasPendentesPesoCarregouMais
    extends ReferenciasPendentesPesoEvent {}

class ReferenciasPendentesPesoAtualizouEmMassa
    extends ReferenciasPendentesPesoEvent {}
