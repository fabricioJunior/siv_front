import 'package:core/equals.dart';

abstract class EcommerceReferenciaProduto implements Equatable {
  int? get id;
  int get ecommerceReferenciaId;
  int get produtoId;
  bool get disponivel;
  String? get corNome;
  String? get tamanhoNome;

  factory EcommerceReferenciaProduto.create({
    int? id,
    required int ecommerceReferenciaId,
    required int produtoId,
    required bool disponivel,
    String? corNome,
    String? tamanhoNome,
  }) = _EcommerceReferenciaProdutoImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceReferenciaId,
        produtoId,
        disponivel,
        corNome,
        tamanhoNome,
      ];
}

class _EcommerceReferenciaProdutoImpl implements EcommerceReferenciaProduto {
  @override
  final int? id;
  @override
  final int ecommerceReferenciaId;
  @override
  final int produtoId;
  @override
  final bool disponivel;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;

  const _EcommerceReferenciaProdutoImpl({
    this.id,
    required this.ecommerceReferenciaId,
    required this.produtoId,
    this.disponivel = true,
    this.corNome,
    this.tamanhoNome,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceReferenciaId,
        produtoId,
        disponivel,
        corNome,
        tamanhoNome,
      ];
}
