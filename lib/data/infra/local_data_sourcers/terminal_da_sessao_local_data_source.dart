import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/terminal_da_sessao_dto.dart';

class TerminalDaSessaoLocalDataSource
    extends IsarLocalDataSourceBase<TerminalDaSessaoDto, TerminalDoUsuario>
    implements ITerminalDaSessaoLocalDataSource<TerminalDaSessaoDto> {
  TerminalDaSessaoLocalDataSource({required super.getIsar});

  @override
  TerminalDaSessaoDto toDto(TerminalDoUsuario entity) {
    return TerminalDaSessaoDto(
      id: entity.id,
      idEmpresa: entity.idEmpresa,
      nome: entity.nome,
    );
  }
}
