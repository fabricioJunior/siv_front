import 'package:core/injecoes.dart';
import 'package:pessoas/data.dart';
import 'package:pessoas/data/remote/pontos_remote_data_source.dart';
import 'package:pessoas/data/repositories/pontos_repository.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_pontos_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';
import 'package:pessoas/presentation/bloc/pontos_bloc/pontos_bloc.dart';
import 'package:pessoas/uses_cases.dart';

import 'domain/data/data_sourcers/remote/i_pessoas_remote_data_source.dart';

void resolverPessoasInjections() {
  _remoteDataSourcers();
  _repositories();
  _usesCases();
  _presentation();
}

void _presentation() {
  sl.registerFactory<PessoasBloc>(
    () => PessoasBloc(
      sl(),
    ),
  );

  sl.registerFactory<PessoaBloc>(
    () => PessoaBloc(
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<PontosBloc>(
    () => PontosBloc(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
}

void _usesCases() {
  sl.registerFactory<CriarPessoa>(
    () => CriarPessoa(
      pessoasRepository: sl(),
    ),
  );
  sl.registerFactory<RecuperarPessoaPeloDocumento>(
    () => RecuperarPessoaPeloDocumento(
      pessoasRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarPessoas>(
    () => RecuperarPessoas(
      pessoasRepository: sl(),
    ),
  );

  sl.registerFactory<SalvarPessoa>(
    () => SalvarPessoa(
      pessoasRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarPessoa>(
    () => RecuperarPessoa(
      pessoasRepository: sl(),
    ),
  );

  sl.registerFactory<CriarPontos>(
    () => CriarPontos(
      pontosRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarPontosDaPessoa>(
    () => RecuperarPontosDaPessoa(
      pontosRepository: sl(),
    ),
  );

  sl.registerFactory<CancelarPonto>(
    () => CancelarPonto(
      pontosRepository: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<IPessoasRepository>(
    () => PessoasRepository(
      remoteDataSource: sl(),
    ),
  );
  sl.registerFactory<IPontosRepository>(
    () => PontosRepository(
      pontosRemoteDataSource: sl(),
    ),
  );
}

void _remoteDataSourcers() {
  sl.registerFactory<IPessoasRemoteDataSource>(
    () => PessoasRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
  sl.registerFactory<IPontosRemoteDataSource>(
    () => PontosRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}
