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
  final String? corNome;
  @override
  final String? tamanhoNome;

  const RomaneioItemDto({
    this.produtoId,
    this.quantidade,
    this.referenciaId,
    this.referenciaNome,
    this.corNome,
    this.tamanhoNome,
  });

  factory RomaneioItemDto.fromJson(Map<String, dynamic> json) {
    return RomaneioItemDto(
      produtoId: _toInt(json['produtoId']),
      quantidade: _toDouble(json['quantidade']),
      referenciaId: _toInt(json['referenciaId']),
      referenciaNome: json['referenciaNome']?.toString(),
      corNome: json['corNome']?.toString(),
      tamanhoNome: json['tamanhoNome']?.toString(),
    );
  }

  factory RomaneioItemDto.fromModel(RomaneioItem item) {
    return RomaneioItemDto(
      produtoId: item.produtoId,
      quantidade: item.quantidade,
      referenciaId: item.referenciaId,
      referenciaNome: item.referenciaNome,
      corNome: item.corNome,
      tamanhoNome: item.tamanhoNome,
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
        corNome,
        tamanhoNome,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => (value as num?)?.toInt();

double? _toDouble(dynamic value) => (value as num?)?.toDouble();
