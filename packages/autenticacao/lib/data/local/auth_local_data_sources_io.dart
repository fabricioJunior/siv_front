import 'package:autenticacao/data/local/dtos/permissao_do_usuario_dto.dart';
import 'package:autenticacao/data/local/dtos/token_dto.dart';
import 'package:autenticacao/data/local/permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/data/local_data_sources.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/models/permissao_do_usuario.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';

void registerAuthLocalDataSources() {
  sl.registerFactory<ITokenLocalDataSource<Token>>(
    () => TokenLocalDataSource(getIsar: _getIsar),
  );

  sl.registerFactory<IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuario>>(
    () => PermissoesDoUsuarioLocalDataSource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    TokenDtoSchema,
    PermissaoDoUsuarioDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    moduleName: 'autenticacao',
  );
}
