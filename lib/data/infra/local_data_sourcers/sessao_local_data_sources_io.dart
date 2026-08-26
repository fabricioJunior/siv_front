import 'package:autenticacao/data.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/empresa_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/licenciado_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/terminal_da_sessao_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/usuario_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/empresa_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/licenciado_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/terminal_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/usuario_da_sessao_local_data_source.dart';

void registerSessaoLocalDataSources() {
  sl.registerFactory<IUsuarioDaSessaoLocalDataSource>(
    () => UsuarioDaSessaoLocalDataSource(getIsar: _getIsar),
  );

  sl.registerFactory<IEmpresaDaSessaoLocalDataSource>(
    () => EmpresaDaSessaoLocalDataSource(getIsar: _getIsar),
  );
  sl.registerFactory<ILicenciadoDaSessaoLocalDataSource>(
    () => LicenciadoDaSessaoLocalDataSource(getIsar: _getIsar),
  );

  sl.registerFactory<ITerminalDaSessaoLocalDataSource>(
    () => TerminalDaSessaoLocalDataSource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    UsuarioDtoSchema,
    EmpresaDtoSchema,
    LicenciadoDtoSchema,
    TerminalDaSessaoDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
  );
}
