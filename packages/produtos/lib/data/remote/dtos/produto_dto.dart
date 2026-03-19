import 'package:produtos/data/remote/dtos/cor_dto.dart';
import 'package:produtos/data/remote/dtos/referencia_dto.dart';
import 'package:produtos/data/remote/dtos/tamanho_dto.dart';
import 'package:produtos/models.dart';

class ProdutoDto implements Produto {
  @override
  final int? id;

  @override
  final int referenciaId;

  @override
  final String idExterno;

  @override
  final int corId;

  @override
  final int tamanhoId;

  ProdutoDto({
    this.id,
    required this.referenciaId,
    required this.idExterno,
    required this.corId,
    required this.tamanhoId,
    this.cor,
    this.referencia,
    this.tamanho,
  });

  factory ProdutoDto.fromJson(Map<String, dynamic> json) {
    return ProdutoDto(
      id: (json['id'] as num?)?.toInt(),
      referenciaId: (json['referenciaId'] as num?)?.toInt() ?? 0,
      idExterno: (json['idExterno'] ?? '').toString(),
      corId: (json['corId'] as num?)?.toInt() ?? 0,
      tamanhoId: (json['tamanhoId'] as num?)?.toInt() ?? 0,
      tamanho: json['tamanho'] != null
          ? TamanhoDto.fromJson(json['tamanho'] as Map<String, dynamic>)
          : null,
      cor: json['cor'] != null
          ? CorDto.fromJson(json['cor'] as Map<String, dynamic>)
          : null,
      referencia: json['referencia'] != null
          ? ReferenciaDto.fromJson(json['referencia'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'referenciaId': referenciaId,
      'idExterno': idExterno,
      'corId': corId,
      'tamanhoId': tamanhoId,
    };
  }

  @override
  List<Object?> get props => [id, referenciaId, idExterno, corId, tamanhoId];

  @override
  bool? get stringify => true;

  @override
  final CorDto? cor;

  @override
  final ReferenciaDto? referencia;

  @override
  final TamanhoDto? tamanho;
}

extension ProdutoToDto on Produto {
  ProdutoDto toDto() {
    return ProdutoDto(
      id: id,
      referenciaId: referenciaId,
      idExterno: idExterno,
      corId: corId,
      tamanhoId: tamanhoId,
    );
  }
}
