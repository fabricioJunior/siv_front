import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/domain/models/codigo.dart';

part 'codigo_dto.g.dart';

@JsonSerializable()
class CodigoDto implements Codigo {
  @override
  final String codigo;

  @override 
  @JsonKey(
    
    unknownEnumValue: TipoCodigo.ean13,fromJson: tipoFromJson  )
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

  static TipoCodigo tipoFromJson(String? tipo) {
    if(tipo == null) {
      return TipoCodigo.ean13; // Valor padrão para casos nulos

    }
    switch (tipo) {
      case 'ean13':
        return TipoCodigo.ean13;
      case 'rfid':
        return TipoCodigo.rfid;
      case 'ean8':
        return TipoCodigo.ean8;
      case 'upca':
        return TipoCodigo.upca;
      case 'upce':
        return TipoCodigo.upce;
      default:
        throw ArgumentError('Tipo de código desconhecido: $tipo');
    }
  }
}
