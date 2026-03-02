part of 'produto_bloc.dart';

enum ProdutoStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class ProdutoState extends Equatable {
  final ProdutoStep produtoStep;
  final int? id;
  final int? referenciaId;
  final String idExterno;
  final int? corId;
  final int? tamanhoId;
  final List<Cor> cores;
  final List<Tamanho> tamanhos;
  final String? erroMensagem;

  const ProdutoState({
    required this.produtoStep,
    this.id,
    this.referenciaId,
    this.idExterno = '',
    this.corId,
    this.tamanhoId,
    this.cores = const [],
    this.tamanhos = const [],
    this.erroMensagem,
  });

  factory ProdutoState.fromModel(
    Produto produto, {
    ProdutoStep step = ProdutoStep.carregado,
    List<Cor> cores = const [],
    List<Tamanho> tamanhos = const [],
  }) {
    return ProdutoState(
      produtoStep: step,
      id: produto.id,
      referenciaId: produto.referenciaId,
      idExterno: produto.idExterno,
      corId: produto.corId,
      tamanhoId: produto.tamanhoId,
      cores: cores,
      tamanhos: tamanhos,
    );
  }

  ProdutoState copyWith({
    ProdutoStep? produtoStep,
    int? id,
    int? referenciaId,
    String? idExterno,
    int? corId,
    int? tamanhoId,
    List<Cor>? cores,
    List<Tamanho>? tamanhos,
    String? erroMensagem,
  }) {
    return ProdutoState(
      produtoStep: produtoStep ?? this.produtoStep,
      id: id ?? this.id,
      referenciaId: referenciaId ?? this.referenciaId,
      idExterno: idExterno ?? this.idExterno,
      corId: corId ?? this.corId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      erroMensagem: erroMensagem,
    );
  }

  @override
  List<Object?> get props => [
    produtoStep,
    id,
    referenciaId,
    idExterno,
    corId,
    tamanhoId,
    cores,
    tamanhos,
    erroMensagem,
  ];
}
