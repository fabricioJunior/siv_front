part of 'terminais_bloc.dart';

abstract class TerminaisEvent extends Equatable {
  const TerminaisEvent();

  @override
  List<Object?> get props => [];
}

class TerminaisIniciou extends TerminaisEvent {
  final int empresaId;
  final String? busca;
  final bool? inativo;

  const TerminaisIniciou({required this.empresaId, this.busca, this.inativo});

  @override
  List<Object?> get props => [empresaId, busca, inativo];
}

class TerminaisDesativar extends TerminaisEvent {
  final int empresaId;
  final int id;

  const TerminaisDesativar({required this.empresaId, required this.id});

  @override
  List<Object?> get props => [empresaId, id];
}
