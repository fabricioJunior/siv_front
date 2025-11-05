part of 'pessoas_bloc.dart';

abstract class PessoasState extends Equatable {
  List<Pessoa> get pessoas => [];

  final int pagina;

  const PessoasState({this.pagina = 0});

  @override
  List<Object?> get props => [pessoas, pagina];
}

class PessoasInitial extends PessoasState {
  const PessoasInitial({super.pagina});
}

class PessoasCarregarEmProgresso extends PessoasState {}

class PessoasCarregarSucesso extends PessoasState {
  @override
  final List<Pessoa> pessoas;

  const PessoasCarregarSucesso({required this.pessoas, required super.pagina});
}

class PessoasCarregarFalha extends PessoasState {}
