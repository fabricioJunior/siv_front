import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/models/permissao_do_usuario.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';

import 'permissoes_do_usuario_indexeddb_data_source.dart';
import 'token_indexeddb_data_source.dart';

void registerAuthLocalDataSources() {
  sl.registerFactory<ITokenLocalDataSource<Token>>(
    () => TokenIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );

  sl.registerFactory<IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuario>>(
    () => PermissoesDoUsuarioIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
