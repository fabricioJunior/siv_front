import 'package:core/isar_anotacoes.dart';
import 'package:autenticacao/models.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'permissao_dto.g.dart';

@Collection(ignore: {'props'})
class PermissaoDto implements Permissao, IsarDto {
  @override
  final String id;

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
  Id get dataBaseId => fastHash(id);

  @override
  List<Object?> get props => [id, nome, descontinuado];

  @override
  bool? get stringify => true;
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
