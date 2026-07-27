part of 'consultar_produto_bloc.dart';

abstract class ConsultarProdutoState extends Equatable {
  GradeDaReferencia? get grade => null;
  String? get mensagemErro => null;

  const ConsultarProdutoState();

  @override
  List<Object?> get props => [grade, mensagemErro];
}

class ConsultarProdutoInitial extends ConsultarProdutoState {
  const ConsultarProdutoInitial();
}

class ConsultarProdutoCarregarEmProgresso extends ConsultarProdutoState {
  const ConsultarProdutoCarregarEmProgresso();
}

class ConsultarProdutoCarregarSucesso extends ConsultarProdutoState {
  @override
  final GradeDaReferencia grade;

  const ConsultarProdutoCarregarSucesso({required this.grade});
}

class ConsultarProdutoCarregarFalha extends ConsultarProdutoState {
  @override
  final String mensagemErro;

  const ConsultarProdutoCarregarFalha({required this.mensagemErro});
}
