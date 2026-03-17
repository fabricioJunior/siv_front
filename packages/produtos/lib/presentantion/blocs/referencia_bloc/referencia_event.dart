part of 'referencia_bloc.dart';

abstract class ReferenciaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciaIniciou extends ReferenciaEvent {
  final int idReferencia;

  ReferenciaIniciou({required this.idReferencia});

  @override
  List<Object?> get props => [idReferencia];
}
