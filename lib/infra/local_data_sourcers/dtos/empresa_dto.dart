import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

@Collection(ignore: {'props'})
class EmpresaDto with Empresa implements IsarDto {
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
