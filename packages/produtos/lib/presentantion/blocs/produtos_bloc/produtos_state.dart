part of 'produtos_bloc.dart';

abstract class ProdutosState extends Equatable {
  final List<Produto> produtos;

  const ProdutosState({this.produtos = const []});

  @override
  List<Object?> get props => [produtos];
}

class ProdutosInitial extends ProdutosState {
  const ProdutosInitial();
}

class ProdutosCarregarEmProgresso extends ProdutosState {
  const ProdutosCarregarEmProgresso();
}

class ProdutosCarregarSucesso extends ProdutosState {
  const ProdutosCarregarSucesso({required super.produtos});
}

class ProdutosCarregarFalha extends ProdutosState {
  const ProdutosCarregarFalha();
}

class ProdutosExcluirEmProgresso extends ProdutosState {
  const ProdutosExcluirEmProgresso({required super.produtos});
}

class ProdutosExcluirSucesso extends ProdutosState {
  const ProdutosExcluirSucesso({required super.produtos});
}

class ProdutosExcluirFalha extends ProdutosState {
  const ProdutosExcluirFalha({required super.produtos});
}
