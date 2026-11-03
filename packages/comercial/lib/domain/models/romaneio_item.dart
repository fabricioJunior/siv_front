import 'package:core/equals.dart';

abstract class RomaneioItem implements Equatable {
  int? get produtoId;
  double? get quantidade;
  int? get referenciaId;
  String? get referenciaNome;
  String? get referenciaDescricao;
  String? get corNome;
  String? get tamanhoNome;
  String? get estampaNome;
  double? get valorUnitario;
  double? get valorUnitDesconto;
  double? get valorTotalBruto;
  double? get valorTotalDesconto;
  double? get valorTotalLiquido;

  factory RomaneioItem.create({
    int? produtoId,
    double? quantidade,
    int? referenciaId,
    String? referenciaNome,
    String? referenciaDescricao,
    String? corNome,
    String? tamanhoNome,
    String? estampaNome,
    double? valorUnitario,
    double? valorUnitDesconto,
    double? valorTotalBruto,
    double? valorTotalDesconto,
    double? valorTotalLiquido,
  }) = _RomaneioItemImpl;

  @override
  List<Object?> get props => [
        produtoId,
        quantidade,
        referenciaId,
        referenciaNome,
        referenciaDescricao,
        corNome,
        tamanhoNome,
        estampaNome,
        valorUnitario,
        valorUnitDesconto,
        valorTotalBruto,
        valorTotalDesconto,
        valorTotalLiquido,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioItemImpl implements RomaneioItem {
  @override
  final int? produtoId;
  @override
  final double? quantidade;
  @override
  final int? referenciaId;
  @override
  final String? referenciaNome;
  @override
  final String? referenciaDescricao;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;
  @override
  final String? estampaNome;
  @override
  final double? valorUnitario;
  @override
  final double? valorUnitDesconto;
  @override
  final double? valorTotalBruto;
  @override
  final double? valorTotalDesconto;
  @override
  final double? valorTotalLiquido;

  const _RomaneioItemImpl({
    this.produtoId,
    this.quantidade,
    this.referenciaId,
    this.referenciaNome,
    this.referenciaDescricao,
    this.corNome,
    this.tamanhoNome,
    this.estampaNome,
    this.valorUnitario,
    this.valorUnitDesconto,
    this.valorTotalBruto,
    this.valorTotalDesconto,
    this.valorTotalLiquido,
  });

  @override
  List<Object?> get props => [
        produtoId,
        quantidade,
        referenciaId,
        referenciaNome,
        referenciaDescricao,
        corNome,
        tamanhoNome,
        estampaNome,
        valorUnitario,
        valorUnitDesconto,
        valorTotalBruto,
        valorTotalDesconto,
        valorTotalLiquido,
      ];

  @override
  bool? get stringify => true;
}
