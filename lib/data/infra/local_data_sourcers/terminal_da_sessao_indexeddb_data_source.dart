import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/terminal_da_sessao_hive_dto.dart';

class TerminalDaSessaoIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<TerminalDaSessaoHiveDto, TerminalDoUsuario>
    implements ITerminalDaSessaoLocalDataSource<TerminalDaSessaoHiveDto> {
  TerminalDaSessaoIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'common_data_TerminalDaSessaoHiveDto',
          fromStorage: TerminalDaSessaoHiveDto.fromStorage,
        );

  @override
  TerminalDaSessaoHiveDto toDto(TerminalDoUsuario entity) {
    return TerminalDaSessaoHiveDto(
      id: entity.id,
      idEmpresa: entity.idEmpresa,
      nome: entity.nome,
    );
  }
}
