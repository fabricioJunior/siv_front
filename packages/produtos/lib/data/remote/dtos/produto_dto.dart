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
  });

  factory ProdutoDto.fromJson(Map<String, dynamic> json) {
    return ProdutoDto(
      id: (json['id'] as num?)?.toInt(),
      referenciaId: (json['referenciaId'] as num?)?.toInt() ?? 0,
      idExterno: (json['idExterno'] ?? '').toString(),
      corId: (json['corId'] as num?)?.toInt() ?? 0,
      tamanhoId: (json['tamanhoId'] as num?)?.toInt() ?? 0,
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
