import 'package:json_annotation/json_annotation.dart';

part 'codigo_de_barras_dto.g.dart';

@JsonSerializable()
class CodigoDeBarrasDto {
  final TipoCodigoDeBarras tipo;
  final String codigo;

  CodigoDeBarrasDto({required this.tipo, required this.codigo});

  factory CodigoDeBarrasDto.fromJson(Map<String, dynamic> json) =>
      _$CodigoDeBarrasDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CodigoDeBarrasDtoToJson(this);
}

enum TipoCodigoDeBarras { ean13, rfid }
