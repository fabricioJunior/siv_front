part of 'categorias_despesa_bloc.dart';

abstract class CategoriasDespesaState extends Equatable {
  final List<CategoriaDespesa> categorias;

  const CategoriasDespesaState({this.categorias = const []});

  @override
  List<Object?> get props => [categorias];
}

class CategoriasDespesaInitial extends CategoriasDespesaState {
  const CategoriasDespesaInitial();
}

class CategoriasDespesaCarregarEmProgresso extends CategoriasDespesaState {
  const CategoriasDespesaCarregarEmProgresso({required super.categorias});
}

class CategoriasDespesaCarregarSucesso extends CategoriasDespesaState {
  const CategoriasDespesaCarregarSucesso({required super.categorias});
}

class CategoriasDespesaCarregarFalha extends CategoriasDespesaState {
  const CategoriasDespesaCarregarFalha({required super.categorias});
}
