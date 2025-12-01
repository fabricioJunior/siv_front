part of 'pontos_bloc.dart';

abstract class PontosState extends Equatable {
  final int? idPessoa;
  final List<Ponto>? pontos;
  final Pessoa? pessoa;

  const PontosState({
    required this.idPessoa,
    required this.pontos,
    this.pessoa,
  });

  PontosState.fromLastState(
    PontosState state, {
    int? idPessoa,
    List<Ponto>? pontos,
    Pessoa? pessoa,
  })  : idPessoa = idPessoa ?? state.idPessoa,
        pontos = pontos ?? state.pontos,
        pessoa = pessoa ?? state.pessoa;

  @override
  List<Object?> get props => [idPessoa, pontos];
}

class PontosInicial extends PontosState {
  const PontosInicial({super.idPessoa, super.pontos});
}

class PontosCarregarEmProgresso extends PontosState {
  const PontosCarregarEmProgresso({required super.idPessoa, super.pontos});
}

class PontosCarregarSucesso extends PontosState {
  PontosCarregarSucesso.fromLastState(
    super.state, {
    required super.pontos,
    required super.pessoa,
  }) : super.fromLastState();
}

class PontosCarregarFalha extends PontosState {
  const PontosCarregarFalha({super.idPessoa, super.pontos});
}

class PontosCriarPontoEmProgresso extends PontosState {
  PontosCriarPontoEmProgresso.fromLastState(
    super.state,
  ) : super.fromLastState();
}

class PontosCriarPontoSucesso extends PontosState {
  PontosCriarPontoSucesso.fromLastState(
    super.state, {
    required super.pontos,
  }) : super.fromLastState();
}

class PontosCriarPontoFalha extends PontosState {
  PontosCriarPontoFalha.fromLastState(
    super.state,
  ) : super.fromLastState();
}
