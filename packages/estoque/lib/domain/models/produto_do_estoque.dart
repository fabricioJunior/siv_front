import 'package:core/equals.dart';

abstract class ProdutoDoEstoque implements Equatable {
  int get empresaId;
  int get referenciaId;
  String? get referenciaIdExterno;
  BigInt get produtoId;
  String? get produtoIdExterno;
  String get nome;
  int get corId;
  String get corNome;
  int get tamanhoId;
  String get tamanhoNome;
  String? get unidadeMedida;
  double get saldo;
  DateTime? get atualizadoEm;

  factory ProdutoDoEstoque.create({
    required int empresaId,
    required int referenciaId,
    required String? referenciaIdExterno,
    required BigInt produtoId,
    required String? produtoIdExterno,
    required String nome,
    required int corId,
    required String corNome,
    required int tamanhoId,
    required String tamanhoNome,
    required String? unidadeMedida,
    required double saldo,
    DateTime? atualizadoEm,
  }) = _ProdutoDoEstoqueImpl;

  @override
  List<Object?> get props => [
    empresaId,
    referenciaId,
    referenciaIdExterno,
    produtoId,
    produtoIdExterno,
    nome,
    corId,
    corNome,
    tamanhoId,
    tamanhoNome,
    unidadeMedida,
    saldo,
    atualizadoEm,
  ];

  @override
  bool? get stringify => true;
}

class _ProdutoDoEstoqueImpl implements ProdutoDoEstoque {
  @override
  final int empresaId;

  @override
  final int referenciaId;

  @override
  final String? referenciaIdExterno;

  @override
  final BigInt produtoId;

  @override
  final String? produtoIdExterno;

  @override
  final String nome;

  @override
  final int corId;

  @override
  final String corNome;

  @override
  final int tamanhoId;

  @override
  final String tamanhoNome;

  @override
  final String? unidadeMedida;

  @override
  final double saldo;

  @override
  final DateTime? atualizadoEm;

  _ProdutoDoEstoqueImpl({
    required this.empresaId,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.produtoId,
    required this.produtoIdExterno,
    required this.nome,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.unidadeMedida,
    required this.saldo,
    this.atualizadoEm,
  });

  _ProdutoDoEstoqueImpl copyWith({
    int? empresaId,
    int? referenciaId,
    String? referenciaIdExterno,
    BigInt? produtoId,
    String? produtoIdExterno,
    String? nome,
    int? corId,
    String? corNome,
    int? tamanhoId,
    String? tamanhoNome,
    String? unidadeMedida,
    double? saldo,
    DateTime? atualizadoEm,
  }) {
    return _ProdutoDoEstoqueImpl(
      empresaId: empresaId ?? this.empresaId,
      referenciaId: referenciaId ?? this.referenciaId,
      referenciaIdExterno: referenciaIdExterno ?? this.referenciaIdExterno,
      produtoId: produtoId ?? this.produtoId,
      produtoIdExterno: produtoIdExterno ?? this.produtoIdExterno,
      nome: nome ?? this.nome,
      corId: corId ?? this.corId,
      corNome: corNome ?? this.corNome,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      tamanhoNome: tamanhoNome ?? this.tamanhoNome,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      saldo: saldo ?? this.saldo,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  List<Object?> get props => [
    empresaId,
    referenciaId,
    referenciaIdExterno,
    produtoId,
    produtoIdExterno,
    nome,
    corId,
    corNome,
    tamanhoId,
    tamanhoNome,
    unidadeMedida,
    saldo,
    atualizadoEm,
  ];

  @override
  bool? get stringify => true;
}

extension ProdutoDoEstoqueCopyWith on ProdutoDoEstoque {
  ProdutoDoEstoque copyWith({
    int? empresaId,
    int? referenciaId,
    String? referenciaIdExterno,
    BigInt? produtoId,
    String? produtoIdExterno,
    String? nome,
    int? corId,
    String? corNome,
    int? tamanhoId,
    String? tamanhoNome,
    String? unidadeMedida,
    double? saldo,
    DateTime? atualizadoEm,
  }) {
    if (this is _ProdutoDoEstoqueImpl) {
      return (this as _ProdutoDoEstoqueImpl).copyWith(
        empresaId: empresaId,
        referenciaId: referenciaId,
        referenciaIdExterno: referenciaIdExterno,
        produtoId: produtoId,
        produtoIdExterno: produtoIdExterno,
        nome: nome,
        corId: corId,
        corNome: corNome,
        tamanhoId: tamanhoId,
        tamanhoNome: tamanhoNome,
        unidadeMedida: unidadeMedida,
        saldo: saldo,
        atualizadoEm: atualizadoEm,
      );
    }
    return ProdutoDoEstoque.create(
      empresaId: empresaId ?? this.empresaId,
      referenciaId: referenciaId ?? this.referenciaId,
      referenciaIdExterno: referenciaIdExterno ?? this.referenciaIdExterno,
      produtoId: produtoId ?? this.produtoId,
      produtoIdExterno: produtoIdExterno ?? this.produtoIdExterno,
      nome: nome ?? this.nome,
      corId: corId ?? this.corId,
      corNome: corNome ?? this.corNome,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      tamanhoNome: tamanhoNome ?? this.tamanhoNome,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      saldo: saldo ?? this.saldo,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
