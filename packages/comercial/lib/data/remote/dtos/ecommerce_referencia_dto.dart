import 'package:comercial/models.dart';

class EcommerceReferenciaDto implements EcommerceReferencia {
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

  const EcommerceReferenciaDto({
    this.id,
    required this.ecommerceId,
    required this.referenciaId,
    this.tabelaDePrecoId,
    this.rascunho = true,
    this.referenciaNome,
  });

  factory EcommerceReferenciaDto.fromJson(Map<String, dynamic> json) {
    return EcommerceReferenciaDto(
      id: _toInt(json['id']),
      ecommerceId: _toInt(json['ecommerceId']) ?? 0,
      referenciaId: _toInt(json['referenciaId']) ?? 0,
      tabelaDePrecoId: _toInt(json['tabelaDePrecoId']),
      rascunho: json['rascunho'] as bool? ?? true,
      referenciaNome: (json['referenciaNome'] ?? json['referencia']?['nome'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referenciaId': referenciaId,
      if (tabelaDePrecoId != null) 'tabelaDePrecoId': tabelaDePrecoId,
      'rascunho': rascunho,
    };
  }

  @override
  List<Object?> get props => [
        id,
        ecommerceId,
        referenciaId,
        tabelaDePrecoId,
        rascunho,
        referenciaNome,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');
