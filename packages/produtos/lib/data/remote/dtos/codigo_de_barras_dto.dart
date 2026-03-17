import 'package:json_annotation/json_annotation.dart';

part 'codigo_de_barras_dto.g.dart';

@JsonSerializable()
class CodigoDeBarrasDto {
  @JsonKey(toJson: _tipoCodigoToJSON)
  final TipoCodigoDeBarras tipo;
  final String codigo;

  CodigoDeBarrasDto({required this.tipo, required this.codigo});
  static String _tipoCodigoToJSON(TipoCodigoDeBarras tipo) {
    return tipo.value;
  }

  factory CodigoDeBarrasDto.fromJson(Map<String, dynamic> json) =>
      _$CodigoDeBarrasDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CodigoDeBarrasDtoToJson(this);
}

enum TipoCodigoDeBarras {
  ean13('EAN13'),
  rfid('RFID');

  final String value;

  const TipoCodigoDeBarras(this.value);
}
