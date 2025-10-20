import 'dart:io';

import 'package:autenticacao/data/local/dtos/token_dto.dart';
import 'package:autenticacao/data/local_data_sources.dart';
import 'package:autenticacao/data/remote/grupo_de_acesso_do_usuario_remote_data_source.dart';
import 'package:autenticacao/data/remote/grupos_de_acesso_remote_data_source.dart';
import 'package:autenticacao/data/remote/permissoes_remote_data_source.dart';
import 'package:autenticacao/data/remote_data_sourcers.dart';
import 'package:autenticacao/data/repositories/grupos_de_acesso_repository.dart';
import 'package:autenticacao/data/repositories/token_repository.dart';
import 'package:autenticacao/data/repositories/usuarios_repository.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_grupos_de_acesso_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/domain/usecases/grupos_de_acesso/recuperar_grupo_de_acessos.dart';
import 'package:autenticacao/domain/usecases/grupos_de_acesso/recuperar_permissoes_do_grupo_de_acesso.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:autenticacao/presentation/bloc/permissoes_bloc/permissoes_bloc.dart';
import 'package:autenticacao/presentation/bloc/usuario_bloc/usuario_bloc.dart';
import 'package:autenticacao/presentation/bloc/usuarios_bloc/usuarios_bloc.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:http/http.dart';

import 'data/remote/permissoes_do_grupo_acesso_remote_data_source.dart';
import 'data/remote/permissoes_do_usuario_remote_data_source.dart';
import 'data/repositories/permissoes_repository.dart';
import 'domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'domain/data/data_sourcers/remote/i_permissoes_remote_data_source.dart';
import 'domain/data/repositories/i_permissoes_repository.dart';
import 'domain/data/repositories/i_token_repository.dart';
import 'presentation/bloc/grupo_de_acesso_bloc/grupo_de_acesso_bloc.dart';
import 'presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';

void resolverDependenciasAutenticacao() {
  _remoteData();
  _localData();
  _repositories();
  _usesCases();
  _presentation();
}

void _presentation() {
  sl.registerFactory<LoginBloc>(
    () => LoginBloc(
      sl(),
      sl(),
    ),
  );
  sl.registerFactory<UsuariosBloc>(() => UsuariosBloc(sl()));
  sl.registerFactory<UsuarioBloc>(() => UsuarioBloc(
        sl(),
        sl(),
        sl(),
        sl(),
      ));

  sl.registerFactory<PermissoesBloc>(
    () => PermissoesBloc(
      recuperarPermissoes: sl(),
    ),
  );
  sl.registerFactory<GruposDeAcessoBloc>(
    () => GruposDeAcessoBloc(
      sl(),
    ),
  );

  sl.registerFactory<GrupoDeAcessoBloc>(
    () => GrupoDeAcessoBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
}

void _usesCases() {
  sl.registerFactory<CriarTokenDeAutenticacao>(
    () => CriarTokenDeAutenticacao(
      repository: sl(),
    ),
  );
  sl.registerFactory<EstaAutenticado>(
    () => EstaAutenticado(
      tokenRepository: sl(),
    ),
  );
  sl.registerFactory<Deslogar>(
    () => Deslogar(
      tokenRepository: sl(),
      usuariosRepository: sl(),
    ),
  );

  sl.registerSingleton<OnAutenticado>(
    OnAutenticado(tokenRepository: sl()),
  );
  sl.registerSingleton<OnDesautenticado>(
    OnDesautenticado(tokenRepository: sl()),
  );
  sl.registerFactory<RecuperarUsuarios>(
    () => RecuperarUsuarios(
      usuariosRepository: sl(),
    ),
  );
  sl.registerFactory<RecuperarUsuario>(
    () => RecuperarUsuario(
      usuariosRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarUsuarioDaSessao>(
    () => RecuperarUsuarioDaSessao(
      usuariosRepository: sl(),
    ),
  );

  sl.registerFactory<SalvarUsuario>(
    () => SalvarUsuario(
      usuariosRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarPermissoes>(
    () => RecuperarPermissoes(
      permissoesRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarGrupoDeAcessos>(
    () => RecuperarGrupoDeAcessos(
      sl(),
    ),
  );
  sl.registerFactory<RecuperarGrupoDeAcesso>(
    () => RecuperarGrupoDeAcesso(
      gruposDeAcessoRepository: sl(),
    ),
  );

  sl.registerFactory<CriarGrupoDeAcesso>(
    () => CriarGrupoDeAcesso(
      gruposDeAcessoRepository: sl(),
    ),
  );

  sl.registerFactory<AtualizarGrupoDeAcesso>(
    () => AtualizarGrupoDeAcesso(
      gruposDeAcessoRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarPermissoesDoGrupoDeAcesso>(
    () => RecuperarPermissoesDoGrupoDeAcesso(
      repository: sl(),
    ),
  );

  sl.registerFactory<VincularUsuarioAoGrupoDeAcesso>(
    () => VincularUsuarioAoGrupoDeAcesso(
      repository: sl(),
    ),
  );
  sl.registerFactory<RecuperarGrupoDeAcessoDoUsuario>(
    () => RecuperarGrupoDeAcessoDoUsuario(
      repository: sl(),
    ),
  );

  sl.registerFactory<ExcluirGrupoDeAcesso>(
    () => ExcluirGrupoDeAcesso(
      repository: sl(),
    ),
  );
}

void _repositories() {
  sl.registerSingleton<ITokenRepository>(
    TokenRepository(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  sl.registerFactory<IUsuariosRepository>(
    () => UsuariosRepository(
      usuariosRemoteDataSource: sl(),
      usuarioDaSessaoRemoteDataSource: sl(),
      usuarioDaSessaoLocalDataSource: sl(),
    ),
  );

  sl.registerFactory<IPermissoesRepository>(
    () => PermissoesRepository(
      sl(),
      sl(),
      sl(),
      permissoesRemoteDataSource: sl(),
    ),
  );

  sl.registerFactory<IGruposDeAcessoRepository>(
    () => GruposDeAcessoRepository(
      gruposDeAcessoRemoteDataSource: sl(),
      permissoesDoGrupoAcessoRemoteDataSource: sl(),
      grupoDeAcessoDoUsuarioRemoteDataSource: sl(),
    ),
  );
}

void _localData() {
  sl.registerFactory<ITokenLocalDataSource>(
    () => TokenLocalDataSource(getIsar: _getIsar),
  );
}

void _remoteData() {
  sl.registerFactory<ITokenRemoteDataSource>(
    () => TokenRemoteDatasource(
      informacoesParaRequest: _InformacoesParaPrimeiraRequest(
        httpClient: HttpSource(
          client: Client(),
        ),
        uriBase: Uri.parse(
          'https://apollo-api-stg.coralcloud.app',
        ),
      ),
    ),
  );

  sl.registerFactory<IGruposDeAcessoRemoteDataSource>(
    () => GruposDeAcessoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
  sl.registerFactory<IPermissoesDoGrupoAcessoRemoteDataSource>(
    () => PermissoesDoGrupoAcessoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IPermissoesDoUsuarioRemoteDataSource>(
    () => PermissoesDoUsuarioRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IPermissoesRemoteDataSource>(
    () => PermissoesRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IGrupoDeAcessoDoUsuarioRemoteDataSource>(
    () => GrupoDeAcessoDoUsuarioRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

class _InformacoesParaPrimeiraRequest extends IInformacoesParaRequests {
  _InformacoesParaPrimeiraRequest({
    required super.httpClient,
    required super.uriBase,
  });
}

// Future<String> getToken() async {
//   if (sl.isRegistered<ITokenRepository>()) {
//     var tokenRepository = sl<ITokenRepository>();
//     var token = await tokenRepository.recuperarToken();
//     if (token == null) {
//       return '';
//     }
//     return token.jwtToken;
//   }
//   return '';
// }

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  var instanceName = '${isSyncData ?? false ? 'sync_' : ''} autenticacao';

  var directory = Directory('${isarDirectory!.path}/$instanceName');

  if (!directory.existsSync()) {
    directory.createSync();
  }
  List<CollectionSchema<dynamic>> schemas = [
    TokenDtoSchema,
  ];

  Isar isar = Isar.getInstance(instanceName) ??
      Isar.openSync(
        schemas,
        directory: directory.path,
        name: instanceName,
        inspector: true,
      );
  return isar;
}
