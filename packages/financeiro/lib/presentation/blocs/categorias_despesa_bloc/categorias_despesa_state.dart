part of 'categorias_despesa_bloc.dart';

abstract class CategoriasDespesaState extends Equatable {
  final List<CategoriaDespesa> categorias;
  final bool salvando;
  final String? erro;

  const CategoriasDespesaState({this.categorias = const [], this.salvando = false, this.erro});

  @override
  List<Object?> get props => [categorias, salvando, erro];
}

class CategoriasDespesaInitial extends CategoriasDespesaState {
  const CategoriasDespesaInitial();
}

class CategoriasDespesaCarregarEmProgresso extends CategoriasDespesaState {
  const CategoriasDespesaCarregarEmProgresso({required super.categorias});
}

class CategoriasDespesaCarregarSucesso extends CategoriasDespesaState {
  const CategoriasDespesaCarregarSucesso({required super.categorias, super.salvando, super.erro});
}

class CategoriasDespesaCarregarFalha extends CategoriasDespesaState {
  const CategoriasDespesaCarregarFalha({required super.categorias});
}
