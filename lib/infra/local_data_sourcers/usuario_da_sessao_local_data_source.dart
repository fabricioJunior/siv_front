import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/usuario_dto.dart';

class UsuarioDaSessaoLocalDataSource
    extends IsarLocalDataSourceBase<UsuarioDto, Usuario>
    implements IUsuarioDaSessaoLocalDataSource<UsuarioDto> {
  UsuarioDaSessaoLocalDataSource({required super.getIsar});

  @override
  UsuarioDto toDto(Usuario entity) {
    return entity.toDto();
  }
}

extension _ToDto on Usuario {
  UsuarioDto toDto() => UsuarioDto(
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
        senha: senha,
      );
}
