part of 'produtos_da_referencia_bloc.dart';

abstract class ProdutosDaReferenciaState extends Equatable {
  final List<Produto> produtos;
  final List<Tamanho> tamanhos;
  final List<Cor> cores;
  final Map<String, Produto> mapaCorTamanhoParaProduto;

  const ProdutosDaReferenciaState({
    this.produtos = const [],
    this.tamanhos = const [],
    this.cores = const [],
    this.mapaCorTamanhoParaProduto = const {},
  });

  @override
  List<Object?> get props => [
    produtos,
    tamanhos,
    cores,
    mapaCorTamanhoParaProduto,
  ];
}

class ProdutosDaReferenciaInitial extends ProdutosDaReferenciaState {
  const ProdutosDaReferenciaInitial();
}

class ProdutosDaReferenciaCarregarEmProgresso
    extends ProdutosDaReferenciaState {
  const ProdutosDaReferenciaCarregarEmProgresso();
}

class ProdutosDaReferenciaCarregarSucesso extends ProdutosDaReferenciaState {
  const ProdutosDaReferenciaCarregarSucesso({
    required super.produtos,
    required super.tamanhos,
    required super.cores,
    required super.mapaCorTamanhoParaProduto,
  });
}

class ProdutosDaReferenciaCarregarFalha extends ProdutosDaReferenciaState {
  const ProdutosDaReferenciaCarregarFalha();
}
