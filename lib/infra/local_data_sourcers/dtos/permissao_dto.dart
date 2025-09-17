import 'package:core/isar_anotacoes.dart';
import 'package:autenticacao/models.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'permissao_dto.g.dart';

@Collection(ignore: {'props'})
class PermissaoDto with Permissao implements IsarDto {
  @override
  final String? id;

  @override
  final String? nome;

  @override
  final bool descontinuado;

  PermissaoDto({
    required this.id,
    required this.nome,
    required this.descontinuado,
  });

  @override
  Id get dataBaseId => fastHash(id ?? 'null');
}

extension PermissaoToDtoExtension on Permissao {
  PermissaoDto toPermissaoDto() {
    return PermissaoDto(
      id: id,
      nome: nome,
      descontinuado: descontinuado,
    );
  }
}
