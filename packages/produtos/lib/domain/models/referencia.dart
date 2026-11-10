import 'package:core/equals.dart';

import 'categoria.dart';
import 'referencia_status_entrada.dart';
import 'sub_categoria.dart';

abstract class Referencia implements Equatable {
  int? get id;
  String get nome;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  String? get idExterno;
  String? get unidadeMedida;
  int? get categoriaId;
  int? get subCategoriaId;
  int? get marcaId;
  String? get descricao;
  String? get composicao;
  String? get cuidados;
  String? get ncm;
  int? get pesoGramas;
  int? get fornecedorId;
  String? get fornecedorNome;
  bool? get aguardandoReposicao;
  DateTime? get previsaoChegada;
  int? get quantidadeEsperada;
  ReferenciaStatusEntrada? get status;
  Categoria? get categoria;
  SubCategoria? get subCategoria;

  factory Referencia.create({
    int? id,
    required String nome,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? idExterno,
    String? unidadeMedida,
    int? categoriaId,
    int? subCategoriaId,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
    int? pesoGramas,
    int? fornecedorId,
    String? fornecedorNome,
    bool? aguardandoReposicao,
    DateTime? previsaoChegada,
    int? quantidadeEsperada,
    ReferenciaStatusEntrada? status,
    Categoria? categoria,
    SubCategoria? subCategoria,
  }) = _ReferenciaImpl;

  @override
  List<Object?> get props => [
    id,
    nome,
    criadoEm,
    atualizadoEm,
    idExterno,
    unidadeMedida,
    categoriaId,
    subCategoriaId,
    marcaId,
    descricao,
    composicao,
    cuidados,
    ncm,
    pesoGramas,
    fornecedorId,
    fornecedorNome,
    aguardandoReposicao,
    previsaoChegada,
    quantidadeEsperada,
    status,
    categoria,
    subCategoria,
  ];

  @override
  bool? get stringify => true;
}

class _ReferenciaImpl implements Referencia {
  @override
  final int? id;
  @override
  final String nome;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;
  @override
  final String? idExterno;
  @override
  final String? unidadeMedida;
  @override
  final int? categoriaId;
  @override
  final int? subCategoriaId;
  @override
  final int? marcaId;
  @override
  final String? descricao;
  @override
  final String? composicao;
  @override
  final String? cuidados;
  @override
  final String? ncm;
  @override
  final int? pesoGramas;
  @override
  final int? fornecedorId;
  @override
  final String? fornecedorNome;
  @override
  final bool? aguardandoReposicao;
  @override
  final DateTime? previsaoChegada;
  @override
  final int? quantidadeEsperada;
  @override
  final ReferenciaStatusEntrada? status;
  @override
  final Categoria? categoria;
  @override
  final SubCategoria? subCategoria;

  _ReferenciaImpl({
    this.id,
    required this.nome,
    this.criadoEm,
    this.atualizadoEm,
    this.idExterno,
    this.unidadeMedida,
    this.categoriaId,
    this.subCategoriaId,
    this.marcaId,
    this.descricao,
    this.composicao,
    this.cuidados,
    this.ncm,
    this.pesoGramas,
    this.fornecedorId,
    this.fornecedorNome,
    this.aguardandoReposicao,
    this.previsaoChegada,
    this.quantidadeEsperada,
    this.status,
    this.categoria,
    this.subCategoria,
  });

  _ReferenciaImpl copyWith({
    int? id,
    String? nome,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? idExterno,
    String? unidadeMedida,
    int? categoriaId,
    int? subCategoriaId,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
    int? pesoGramas,
    int? fornecedorId,
    String? fornecedorNome,
    bool? aguardandoReposicao,
    DateTime? previsaoChegada,
    int? quantidadeEsperada,
    ReferenciaStatusEntrada? status,
    Categoria? categoria,
    SubCategoria? subCategoria,
  }) {
    return _ReferenciaImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      idExterno: idExterno ?? this.idExterno,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      categoriaId: categoriaId ?? this.categoriaId,
      subCategoriaId: subCategoriaId ?? this.subCategoriaId,
      marcaId: marcaId ?? this.marcaId,
      descricao: descricao ?? this.descricao,
      composicao: composicao ?? this.composicao,
      cuidados: cuidados ?? this.cuidados,
      ncm: ncm ?? this.ncm,
      pesoGramas: pesoGramas ?? this.pesoGramas,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      fornecedorNome: fornecedorNome ?? this.fornecedorNome,
      aguardandoReposicao: aguardandoReposicao ?? this.aguardandoReposicao,
      previsaoChegada: previsaoChegada ?? this.previsaoChegada,
      quantidadeEsperada: quantidadeEsperada ?? this.quantidadeEsperada,
      status: status ?? this.status,
      categoria: categoria ?? this.categoria,
      subCategoria: subCategoria ?? this.subCategoria,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    criadoEm,
    atualizadoEm,
    idExterno,
    unidadeMedida,
    categoriaId,
    subCategoriaId,
    marcaId,
    descricao,
    composicao,
    cuidados,
    ncm,
    pesoGramas,
    fornecedorId,
    fornecedorNome,
    aguardandoReposicao,
    previsaoChegada,
    quantidadeEsperada,
    status,
    categoria,
    subCategoria,
  ];

  @override
  bool? get stringify => true;
}

extension ReferenciaCopyWith on Referencia {
  Referencia copyWith({
    int? id,
    String? nome,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? idExterno,
    String? unidadeMedida,
    int? categoriaId,
    int? subCategoriaId,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
    int? pesoGramas,
    int? fornecedorId,
    String? fornecedorNome,
    bool? aguardandoReposicao,
    DateTime? previsaoChegada,
    int? quantidadeEsperada,
    ReferenciaStatusEntrada? status,
    Categoria? categoria,
    SubCategoria? subCategoria,
  }) {
    if (this is _ReferenciaImpl) {
      return (this as _ReferenciaImpl).copyWith(
        id: id,
        nome: nome,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        idExterno: idExterno,
        unidadeMedida: unidadeMedida,
        categoriaId: categoriaId,
        subCategoriaId: subCategoriaId,
        marcaId: marcaId,
        descricao: descricao,
        composicao: composicao,
        cuidados: cuidados,
        ncm: ncm,
        pesoGramas: pesoGramas,
        fornecedorId: fornecedorId,
        fornecedorNome: fornecedorNome,
        aguardandoReposicao: aguardandoReposicao,
        previsaoChegada: previsaoChegada,
        quantidadeEsperada: quantidadeEsperada,
        status: status,
        categoria: categoria,
        subCategoria: subCategoria,
      );
    }

    return Referencia.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      idExterno: idExterno ?? this.idExterno,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      categoriaId: categoriaId ?? this.categoriaId,
      subCategoriaId: subCategoriaId ?? this.subCategoriaId,
      marcaId: marcaId ?? this.marcaId,
      descricao: descricao ?? this.descricao,
      composicao: composicao ?? this.composicao,
      cuidados: cuidados ?? this.cuidados,
      ncm: ncm ?? this.ncm,
      pesoGramas: pesoGramas ?? this.pesoGramas,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      fornecedorNome: fornecedorNome ?? this.fornecedorNome,
      aguardandoReposicao: aguardandoReposicao ?? this.aguardandoReposicao,
      previsaoChegada: previsaoChegada ?? this.previsaoChegada,
      quantidadeEsperada: quantidadeEsperada ?? this.quantidadeEsperada,
      status: status ?? this.status,
      categoria: categoria ?? this.categoria,
      subCategoria: subCategoria ?? this.subCategoria,
    );
  }
}
