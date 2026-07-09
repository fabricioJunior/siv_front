import 'package:comercial/models.dart';

class RomaneioItemDevolvidoDto implements RomaneioItemDevolvido {
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

  const RomaneioItemDevolvidoDto({
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

  factory RomaneioItemDevolvidoDto.fromJson(Map<String, dynamic> json) {
    return RomaneioItemDevolvidoDto(
      produtoId: _toInt(json['produtoId']),
      referenciaId: _toInt(json['referenciaId']),
      referenciaNome: json['referenciaNome']?.toString(),
      referenciaDescricao: json['referenciaDescricao']?.toString(),
      corNome: json['corNome']?.toString(),
      tamanhoNome: json['tamanhoNome']?.toString(),
      quantidade: _toDouble(json['quantidade']),
      romaneioId: _toInt(json['romaneioId']),
      sequencia: _toInt(json['sequencia']),
      romaneioDevolucaoId: _toInt(json['romaneioDevolucaoId']),
      romaneioDevolucaoSequencia: _toInt(json['romaneioDevolucaoSequencia']),
      valorUnitario: _toDouble(json['valorUnitario']),
      valorTotalDesconto: _toDouble(json['valorTotalDesconto']),
      valorTotalLiquido: _toDouble(json['valorTotalLiquido']),
    );
  }

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

int? _toInt(dynamic value) => (value as num?)?.toInt();

double? _toDouble(dynamic value) => (value as num?)?.toDouble();
