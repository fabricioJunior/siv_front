part of 'pessoas_bloc.dart';

abstract class PessoasState extends Equatable {
  List<Pessoa> get pessoas => [];

  @override
  List<Object?> get props => [pessoas];
}

class PessoasInitial extends PessoasState {}

class PessoasCarregarEmProgresso extends PessoasState {}

class PessoasCarregarSucesso extends PessoasState {
  @override
  final List<Pessoa> pessoas;

  PessoasCarregarSucesso({required this.pessoas});
}

class PessoasCarregarFalha extends PessoasState {}
