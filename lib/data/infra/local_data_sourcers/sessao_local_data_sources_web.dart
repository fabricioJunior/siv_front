import 'package:autenticacao/data.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:hive_ce/hive.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/empresa_hive_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/licenciado_hive_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/terminal_da_sessao_hive_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/usuario_hive_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/empresa_da_sessao_hive_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/licenciado_da_sessao_hive_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/terminal_da_sessao_hive_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/usuario_da_sessao_hive_data_source.dart';

void registerSessaoLocalDataSources() {
  sl.registerFactory<IUsuarioDaSessaoLocalDataSource>(
    () => UsuarioDaSessaoHiveDataSource(getBox: _getUsuarioBox),
  );

  sl.registerFactory<IEmpresaDaSessaoLocalDataSource>(
    () => EmpresaDaSessaoHiveDataSource(getBox: _getEmpresaBox),
  );
  sl.registerFactory<ILicenciadoDaSessaoLocalDataSource>(
    () => LicenciadoDaSessaoHiveDataSource(getBox: _getLicenciadoBox),
  );

  sl.registerFactory<ITerminalDaSessaoLocalDataSource>(
    () => TerminalDaSessaoHiveDataSource(getBox: _getTerminalDaSessaoBox),
  );
}

Future<Box<UsuarioHiveDto>> _getUsuarioBox() {
  return sl<IHiveDatabaseInstance>().getBox<UsuarioHiveDto>(
    adapters: [
      StorageEntityAdapter<UsuarioHiveDto>(UsuarioHiveDto.fromStorage),
    ],
    isCommonData: true,
    boxKey: 'UsuarioHiveDto',
  );
}

Future<Box<EmpresaHiveDto>> _getEmpresaBox() {
  return sl<IHiveDatabaseInstance>().getBox<EmpresaHiveDto>(
    adapters: [
      StorageEntityAdapter<EmpresaHiveDto>(EmpresaHiveDto.fromStorage),
    ],
    isCommonData: true,
    boxKey: 'EmpresaHiveDto',
  );
}

Future<Box<LicenciadoHiveDto>> _getLicenciadoBox() {
  return sl<IHiveDatabaseInstance>().getBox<LicenciadoHiveDto>(
    adapters: [
      StorageEntityAdapter<LicenciadoHiveDto>(LicenciadoHiveDto.fromStorage),
    ],
    boxKey: 'LicenciadoHiveDto',
    isCommonData: true,
  );
}

Future<Box<TerminalDaSessaoHiveDto>> _getTerminalDaSessaoBox() {
  return sl<IHiveDatabaseInstance>().getBox<TerminalDaSessaoHiveDto>(
    adapters: [
      StorageEntityAdapter<TerminalDaSessaoHiveDto>(
        TerminalDaSessaoHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    boxKey: 'TerminalDaSessaoHiveDto',
  );
}
