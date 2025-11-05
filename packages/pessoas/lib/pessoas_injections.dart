import 'package:core/injecoes.dart';
import 'package:pessoas/data.dart';
import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';
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
}

void _repositories() {
  sl.registerFactory<IPessoasRepository>(
    () => PessoasRepository(
      remoteDataSource: sl(),
    ),
  );
}

void _remoteDataSourcers() {
  sl.registerFactory<IPessoasRemoteDataSource>(
    () => PessoasRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}
