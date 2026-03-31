import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';

part 'empresa_dto.g.dart';

@Collection(ignore: {'props'})
class EmpresaDto implements Empresa, IsarDto {
  @override
  Id get dataBaseId => id;

  @override
  final int id;

  @override
  final String nome;

  EmpresaDto({
    required this.id,
    required this.nome,
  });
}
