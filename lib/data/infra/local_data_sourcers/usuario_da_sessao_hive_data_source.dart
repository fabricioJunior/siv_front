import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/usuario_hive_dto.dart';

class UsuarioDaSessaoHiveDataSource
    extends HiveLocalDataSourceBase<UsuarioHiveDto, Usuario>
    implements IUsuarioDaSessaoLocalDataSource<UsuarioHiveDto> {
  UsuarioDaSessaoHiveDataSource({required super.getBox});

  @override
  UsuarioHiveDto toDto(Usuario entity) {
    return UsuarioHiveDto(
      id: entity.id,
      login: entity.login,
      nome: entity.nome,
      tipo: entity.tipo,
      senha: entity.senha,
      ativo: entity.ativo,
    );
  }
}
