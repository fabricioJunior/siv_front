part of 'variacoes_produto_bloc.dart';

abstract class VariacoesProdutoEvent extends Equatable {
  const VariacoesProdutoEvent();

  @override
  List<Object?> get props => [];
}

/// Pré-carga das três listas; reenviar refaz só as que não carregaram.
class VariacoesCarregadas extends VariacoesProdutoEvent {
  const VariacoesCarregadas();
}

class VariacoesCorCadastrada extends VariacoesProdutoEvent {
  final String nome;
  const VariacoesCorCadastrada(this.nome);

  @override
  List<Object?> get props => [nome];
}

class VariacoesEstampaCadastrada extends VariacoesProdutoEvent {
  final String nome;
  const VariacoesEstampaCadastrada(this.nome);

  @override
  List<Object?> get props => [nome];
}
