part of 'variacoes_produto_bloc.dart';

enum VariacaoStatus { carregando, sucesso, falha }

class VariacaoLista<T> extends Equatable {
  final VariacaoStatus status;
  final List<T> itens;

  /// Último item cadastrado / erro do último cadastro (limpos a cada mudança).
  final T? ultimoCadastrado;
  final String? erro;

  const VariacaoLista({
    this.status = VariacaoStatus.carregando,
    this.itens = const [],
    this.ultimoCadastrado,
    this.erro,
  });

  VariacaoLista<T> copyWith({
    VariacaoStatus? status,
    List<T>? itens,
    T? ultimoCadastrado,
    String? erro,
  }) =>
      VariacaoLista<T>(
        status: status ?? this.status,
        itens: itens ?? this.itens,
        ultimoCadastrado: ultimoCadastrado,
        erro: erro,
      );

  @override
  List<Object?> get props => [status, itens, ultimoCadastrado, erro];
}

class VariacoesProdutoState extends Equatable {
  final VariacaoLista<VariacaoOpcao> cores;
  final VariacaoLista<VariacaoOpcao> estampas;
  final VariacaoLista<TamanhoOpcao> tamanhos;

  const VariacoesProdutoState({
    this.cores = const VariacaoLista(),
    this.estampas = const VariacaoLista(),
    this.tamanhos = const VariacaoLista(),
  });

  VariacoesProdutoState copyWith({
    VariacaoLista<VariacaoOpcao>? cores,
    VariacaoLista<VariacaoOpcao>? estampas,
    VariacaoLista<TamanhoOpcao>? tamanhos,
  }) =>
      VariacoesProdutoState(
        cores: cores ?? this.cores,
        estampas: estampas ?? this.estampas,
        tamanhos: tamanhos ?? this.tamanhos,
      );

  @override
  List<Object?> get props => [cores, estampas, tamanhos];
}
