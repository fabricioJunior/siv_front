import 'package:core/equals.dart';

abstract class RomaneioItemDevolvido implements Equatable {
  int? get produtoId;
  int? get referenciaId;
  String? get referenciaNome;
  String? get referenciaDescricao;
  String? get corNome;
  String? get tamanhoNome;
  double? get quantidade;
  int? get romaneioId;
  int? get sequencia;
  int? get romaneioDevolucaoId;
  int? get romaneioDevolucaoSequencia;
  double? get valorUnitario;
  double? get valorTotalDesconto;
  double? get valorTotalLiquido;

  factory RomaneioItemDevolvido.create({
    int? produtoId,
    int? referenciaId,
    String? referenciaNome,
    String? referenciaDescricao,
    String? corNome,
    String? tamanhoNome,
    double? quantidade,
    int? romaneioId,
    int? sequencia,
    int? romaneioDevolucaoId,
    int? romaneioDevolucaoSequencia,
    double? valorUnitario,
    double? valorTotalDesconto,
    double? valorTotalLiquido,
  }) = _RomaneioItemDevolvidoImpl;

  @override
  List<Object?> get props => [
        produtoId,
        referenciaId,
        referenciaNome,
        referenciaDescricao,
        corNome,
        tamanhoNome,
        quantidade,
        romaneioId,
        sequencia,
        romaneioDevolucaoId,
        romaneioDevolucaoSequencia,
        valorUnitario,
        valorTotalDesconto,
        valorTotalLiquido,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioItemDevolvidoImpl implements RomaneioItemDevolvido {
  @override
  final int? produtoId;
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
  final double? quantidade;
  @override
  final int? romaneioId;
  @override
  final int? sequencia;
  @override
  final int? romaneioDevolucaoId;
  @override
  final int? romaneioDevolucaoSequencia;
  @override
  final double? valorUnitario;
  @override
  final double? valorTotalDesconto;
  @override
  final double? valorTotalLiquido;

  const _RomaneioItemDevolvidoImpl({
    this.produtoId,
    this.referenciaId,
    this.referenciaNome,
    this.referenciaDescricao,
    this.corNome,
    this.tamanhoNome,
    this.quantidade,
    this.romaneioId,
    this.sequencia,
    this.romaneioDevolucaoId,
    this.romaneioDevolucaoSequencia,
    this.valorUnitario,
    this.valorTotalDesconto,
    this.valorTotalLiquido,
  });

  @override
  List<Object?> get props => [
        produtoId,
        referenciaId,
        referenciaNome,
        referenciaDescricao,
        corNome,
        tamanhoNome,
        quantidade,
        romaneioId,
        sequencia,
        romaneioDevolucaoId,
        romaneioDevolucaoSequencia,
        valorUnitario,
        valorTotalDesconto,
        valorTotalLiquido,
      ];

  @override
  bool? get stringify => true;
}
