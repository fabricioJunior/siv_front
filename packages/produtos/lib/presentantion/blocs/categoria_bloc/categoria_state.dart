part of 'categoria_bloc.dart';

enum CategoriaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}

class CategoriaState extends Equatable {
  final CategoriaStep categoriaStep;
  final String? nome;
  final int? id;
  final bool inativa;
  final String? ncm;
  final String? descricao;
  final String? icone;
  final int? pesoGramas;

  const CategoriaState({
    required this.categoriaStep,
    this.nome,
    this.id,
    this.inativa = false,
    this.ncm,
    this.descricao,
    this.icone,
    this.pesoGramas,
  });

  factory CategoriaState.fromModel(
    Categoria categoria, {
    CategoriaStep step = CategoriaStep.carregado,
  }) {
    return CategoriaState(
      categoriaStep: step,
      nome: categoria.nome,
      id: categoria.id,
      inativa: categoria.inativa,
      ncm: categoria.ncm,
      descricao: categoria.descricao,
      icone: categoria.icone,
      pesoGramas: categoria.pesoGramas,
    );
  }

  CategoriaState copyWith({
    CategoriaStep? categoriaStep,
    String? nome,
    int? id,
    bool? inativa,
    Object? ncm = _sentinel,
    Object? descricao = _sentinel,
    Object? icone = _sentinel,
    Object? pesoGramas = _sentinel,
  }) {
    return CategoriaState(
      categoriaStep: categoriaStep ?? this.categoriaStep,
      nome: nome ?? this.nome,
      id: id ?? this.id,
      inativa: inativa ?? this.inativa,
      ncm: ncm == _sentinel ? this.ncm : ncm as String?,
      descricao: descricao == _sentinel ? this.descricao : descricao as String?,
      icone: icone == _sentinel ? this.icone : icone as String?,
      pesoGramas: pesoGramas == _sentinel ? this.pesoGramas : pesoGramas as int?,
    );
  }

  @override
  List<Object?> get props =>
      [categoriaStep, nome, id, inativa, ncm, descricao, icone, pesoGramas];
}

const _sentinel = Object();
