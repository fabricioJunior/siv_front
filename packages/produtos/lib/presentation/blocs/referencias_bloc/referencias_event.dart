part of 'referencias_bloc.dart';

abstract class ReferenciasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciasIniciou extends ReferenciasEvent {
  final String? busca;
  final bool? inativo;

  ReferenciasIniciou({this.busca, this.inativo});

  @override
  List<Object?> get props => [busca, inativo];
}
