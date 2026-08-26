import 'package:autenticacao/data/local/dtos/permissao_do_usuario_hive_dto.dart';
import 'package:autenticacao/data/local/dtos/token_hive_dto.dart';
import 'package:autenticacao/data/local/permissoes_do_usuario_hive_data_source.dart';
import 'package:autenticacao/data/local/token_hive_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/models/permissao_do_usuario.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:hive_ce/hive.dart';

void registerAuthLocalDataSources() {
  sl.registerFactory<ITokenLocalDataSource<Token>>(
    () => TokenHiveDataSource(getBox: _getTokenBox),
  );

  sl.registerFactory<IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuario>>(
    () => PermissoesDoUsuarioHiveDataSource(getBox: _getPermissaoDoUsuarioBox),
  );
}

Future<Box<TokenHiveDto>> _getTokenBox() {
  return sl<IHiveDatabaseInstance>().getBox<TokenHiveDto>(
    boxKey: 'TokenHiveDto',
    adapters: [StorageEntityAdapter<TokenHiveDto>(TokenHiveDto.fromStorage)],
    moduleName: 'autenticacao',
  );
}

Future<Box<PermissaoDoUsuarioHiveDto>> _getPermissaoDoUsuarioBox() {
  return sl<IHiveDatabaseInstance>().getBox<PermissaoDoUsuarioHiveDto>(
    boxKey: 'PermissaoDoUsuarioHiveDto',
    adapters: [
      StorageEntityAdapter<PermissaoDoUsuarioHiveDto>(
        PermissaoDoUsuarioHiveDto.fromStorage,
      ),
    ],
    moduleName: 'autenticacao',
  );
}
