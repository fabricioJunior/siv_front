part of 'referencias_pendentes_ncm_bloc.dart';

abstract class ReferenciasPendentesNcmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciasPendentesNcmIniciou extends ReferenciasPendentesNcmEvent {}

class ReferenciasPendentesNcmBuscou extends ReferenciasPendentesNcmEvent {
  final String? search;
  final String? orderBy;
  final String? orderDir;

  ReferenciasPendentesNcmBuscou({this.search, this.orderBy, this.orderDir});

  @override
  List<Object?> get props => [search, orderBy, orderDir];
}

class ReferenciasPendentesNcmCarregouMais
    extends ReferenciasPendentesNcmEvent {}

class ReferenciasPendentesNcmAtualizouEmMassa
    extends ReferenciasPendentesNcmEvent {}
