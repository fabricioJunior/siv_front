part of 'tamanhos_bloc.dart';

abstract class TamanhosState extends Equatable {
  List<Tamanho> get tamanhos => [];

  const TamanhosState();

  @override
  List<Object?> get props => [tamanhos];
}

class TamanhosInitial extends TamanhosState {
  const TamanhosInitial();
}

class TamanhosCarregarEmProgresso extends TamanhosState {
  const TamanhosCarregarEmProgresso();
}

class TamanhosCarregarSucesso extends TamanhosState {
  @override
  final List<Tamanho> tamanhos;

  const TamanhosCarregarSucesso({required this.tamanhos});
}

class TamanhosCarregarFalha extends TamanhosState {
  const TamanhosCarregarFalha();
}

class TamanhosDesativarEmProgresso extends TamanhosState {
  @override
  final List<Tamanho> tamanhos;

  const TamanhosDesativarEmProgresso({required this.tamanhos});
}

class TamanhosDesativarSucesso extends TamanhosState {
  @override
  final List<Tamanho> tamanhos;

  const TamanhosDesativarSucesso({required this.tamanhos});
}

class TamanhosDesativarFalha extends TamanhosState {
  @override
  final List<Tamanho> tamanhos;

  const TamanhosDesativarFalha({required this.tamanhos});
}
