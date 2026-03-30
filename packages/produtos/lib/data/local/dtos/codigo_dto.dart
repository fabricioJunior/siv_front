import 'package:core/isar_anotacoes.dart';
import 'package:produtos/domain/models/codigo.dart';
part 'codigo_dto.g.dart';

@Collection(ignore: {'tipo'})
class CodigoDto extends Codigo implements IsarDto {
  @override
  final String codigo;

  @override
  final int produtoId;

  final int tipoIndex;

  CodigoDto({
    required this.codigo,
    required this.produtoId,
    required this.tipoIndex,
  });

  @override
  @ignore
  TipoCodigo get tipo => TipoCodigo.values[tipoIndex];

  @override
  Id get dataBaseId => fastHash(codigo);
}
