import 'package:core/equals.dart';

abstract class EcommerceReferencia implements Equatable {
  int? get id;
  int get ecommerceId;
  int get referenciaId;
  int? get tabelaDePrecoId;
  bool get rascunho;
  String? get referenciaNome;

  factory EcommerceReferencia.create({
    int? id,
    required int ecommerceId,
    required int referenciaId,
    int? tabelaDePrecoId,
    required bool rascunho,
    String? referenciaNome,
  }) = _EcommerceReferenciaImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
      ];
}

class _EcommerceReferenciaImpl implements EcommerceReferencia {
  @override
  final int? id;
  @override
  final int ecommerceId;
  @override
  final int referenciaId;
  @override
  final int? tabelaDePrecoId;
  @override
  final bool rascunho;
  @override
  final String? referenciaNome;

  const _EcommerceReferenciaImpl({
    this.id,
    required this.ecommerceId,
    required this.referenciaId,
    this.tabelaDePrecoId,
    this.rascunho = true,
    this.referenciaNome,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
      ];
}
