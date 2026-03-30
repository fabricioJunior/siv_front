import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/domain/models/codigo.dart';

part 'codigo_dto.g.dart';

@JsonSerializable()
class CodigoDto implements Codigo {
  @override
  final String codigo;

  @override
  final TipoCodigo tipo;

  @override
  final int produtoId;

  CodigoDto({
    required this.codigo,
    required this.tipo,
    required this.produtoId,
  });

  factory CodigoDto.fromJson(Map<String, dynamic> json) =>
      _$CodigoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CodigoDtoToJson(this);
}
