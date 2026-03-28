// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_do_estoque_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProdutoDoEstoqueDto _$ProdutoDoEstoqueDtoFromJson(Map<String, dynamic> json) =>
    ProdutoDoEstoqueDto(
      empresaId: (json['empresaId'] as num).toInt(),
      referenciaId: (json['referenciaId'] as num).toInt(),
      referenciaIdExterno: json['referenciaIdExterno'] as String?,
      produtoId: ProdutoDoEstoqueDto._bigIntFromJson(json['produtoId']),
      produtoIdExterno: json['produtoIdExterno'] as String?,
      nome: json['nome'] as String,
      corId: (json['corId'] as num).toInt(),
      corNome: json['corNome'] as String,
      tamanhoId: (json['tamanhoId'] as num).toInt(),
      tamanhoNome: json['tamanhoNome'] as String,
      unidadeMedida: json['unidadeMedida'] as String?,
      saldo: (json['saldo'] as num).toDouble(),
      atualizadoEm: json['atualizadoEm'] == null
          ? null
          : DateTime.parse(json['atualizadoEm'] as String),
    );

Map<String, dynamic> _$ProdutoDoEstoqueDtoToJson(
  ProdutoDoEstoqueDto instance,
) => <String, dynamic>{
  'empresaId': instance.empresaId,
  'referenciaId': instance.referenciaId,
  'referenciaIdExterno': instance.referenciaIdExterno,
  'produtoId': instance.produtoId.toString(),
  'produtoIdExterno': instance.produtoIdExterno,
  'nome': instance.nome,
  'corId': instance.corId,
  'corNome': instance.corNome,
  'tamanhoId': instance.tamanhoId,
  'tamanhoNome': instance.tamanhoNome,
  'unidadeMedida': instance.unidadeMedida,
  'saldo': instance.saldo,
  'atualizadoEm': instance.atualizadoEm?.toIso8601String(),
};
