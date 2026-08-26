import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/terminal_da_sessao_hive_dto.dart';

class TerminalDaSessaoHiveDataSource
    extends HiveLocalDataSourceBase<TerminalDaSessaoHiveDto, TerminalDoUsuario>
    implements ITerminalDaSessaoLocalDataSource<TerminalDaSessaoHiveDto> {
  TerminalDaSessaoHiveDataSource({required super.getBox});

  @override
  TerminalDaSessaoHiveDto toDto(TerminalDoUsuario entity) {
    return TerminalDaSessaoHiveDto(
      id: entity.id,
      idEmpresa: entity.idEmpresa,
      nome: entity.nome,
    );
  }
}
