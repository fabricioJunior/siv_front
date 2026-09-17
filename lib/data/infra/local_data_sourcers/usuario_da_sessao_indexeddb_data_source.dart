import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/usuario_hive_dto.dart';

class UsuarioDaSessaoIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<UsuarioHiveDto, Usuario>
    implements IUsuarioDaSessaoLocalDataSource<UsuarioHiveDto> {
  UsuarioDaSessaoIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'common_data_UsuarioHiveDto',
          fromStorage: UsuarioHiveDto.fromStorage,
        );

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
