import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/usuario_dto.dart';

class UsuarioDaSessaLocalDataSource
    extends IsarLocalDataSourceBase<UsuarioDto, Usuario>
    implements IUsuarioDaSessaoLocalDataSource<UsuarioDto> {
  UsuarioDaSessaLocalDataSource({required super.getIsar});

  @override
  UsuarioDto toDto(Usuario entity) {
    return entity.toDto();
  }
}

extension _ToDto on Usuario {
  UsuarioDto toDto() => UsuarioDto(
        atualizadoEm: atualizadoEm,
        criadoEm: criadoEm,
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
      );
}
