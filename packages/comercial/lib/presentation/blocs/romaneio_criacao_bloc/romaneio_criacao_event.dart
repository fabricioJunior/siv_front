part of 'romaneio_criacao_bloc.dart';

abstract class RomaneioCriacaoEvent extends Equatable {
  const RomaneioCriacaoEvent();

  @override
  List<Object?> get props => [];
}

class RomaneioCriacaoSolicitada extends RomaneioCriacaoEvent {
  final Map<String, dynamic> parametros;

  const RomaneioCriacaoSolicitada({required this.parametros});

  @override
  List<Object?> get props => [parametros];
}
