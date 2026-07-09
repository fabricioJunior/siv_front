import 'package:comercial/models.dart';

class RomaneioItemDto implements RomaneioItem {
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
  final double? valorUnitario;
  @override
  final double? valorUnitDesconto;
  @override
  final double? valorTotalBruto;
  @override
  final double? valorTotalDesconto;
  @override
  final double? valorTotalLiquido;

  const RomaneioItemDto({
    this.produtoId,
    this.quantidade,
    this.referenciaId,
    this.referenciaNome,
    this.referenciaDescricao,
    this.corNome,
    this.tamanhoNome,
    this.valorUnitario,
    this.valorUnitDesconto,
    this.valorTotalBruto,
    this.valorTotalDesconto,
    this.valorTotalLiquido,
  });

  factory RomaneioItemDto.fromJson(Map<String, dynamic> json) {
    return RomaneioItemDto(
      produtoId: _toInt(json['produtoId']),
      quantidade: _toDouble(json['quantidade']),
      referenciaId: _toInt(json['referenciaId']),
      referenciaNome: json['referenciaNome']?.toString(),
      referenciaDescricao: json['referenciaDescricao']?.toString(),
      corNome: json['corNome']?.toString(),
      tamanhoNome: json['tamanhoNome']?.toString(),
      valorUnitario: _toDouble(json['valorUnitario']),
      valorUnitDesconto: _toDouble(json['valorUnitDesconto']),
      valorTotalBruto: _toDouble(json['valorTotalBruto']),
      valorTotalDesconto: _toDouble(json['valorTotalDesconto']),
      valorTotalLiquido: _toDouble(json['valorTotalLiquido']),
    );
  }

  factory RomaneioItemDto.fromModel(RomaneioItem item) {
    return RomaneioItemDto(
      produtoId: item.produtoId,
      quantidade: item.quantidade,
      referenciaId: item.referenciaId,
      referenciaNome: item.referenciaNome,
      referenciaDescricao: item.referenciaDescricao,
      corNome: item.corNome,
      tamanhoNome: item.tamanhoNome,
      valorUnitario: item.valorUnitario,
      valorUnitDesconto: item.valorUnitDesconto,
      valorTotalBruto: item.valorTotalBruto,
      valorTotalDesconto: item.valorTotalDesconto,
      valorTotalLiquido: item.valorTotalLiquido,
    );
  }

  Map<String, dynamic> toAddRemoveJson() {
    return {
      'produtoId': produtoId,
      'quantidade': quantidade,
    };
  }

  @override
  List<Object?> get props => [
        produtoId,
        quantidade,
        referenciaId,
        referenciaNome,
        referenciaDescricao,
        corNome,
        tamanhoNome,
        valorUnitario,
        valorUnitDesconto,
        valorTotalBruto,
        valorTotalDesconto,
        valorTotalLiquido,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => (value as num?)?.toInt();

double? _toDouble(dynamic value) => (value as num?)?.toDouble();
