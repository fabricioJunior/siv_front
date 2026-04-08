import 'package:core/injecoes.dart';
import 'package:pessoas/data.dart';
import 'package:pessoas/data/remote/pontos_remote_data_source.dart';
import 'package:pessoas/data/repositories/pontos_repository.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_enderecos_remote_data_source.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_funcionarios_remote_data_source.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_pontos_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';
import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/presentation/bloc/endereco_cadastro_bloc/endereco_cadastro_bloc.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/bloc/funcionarios_bloc/funcionarios_bloc.dart';
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
      sl(),
    ),
  );

  sl.registerFactory<PontosBloc>(
    () => PontosBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<EnderecosBloc>(
    () => EnderecosBloc(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<EnderecoCadastroBloc>(
    () => EnderecoCadastroBloc(
      cepService: sl(),
    ),
  );

  sl.registerFactory<FuncionariosBloc>(
    () => FuncionariosBloc(
      sl(),
    ),
  );

  sl.registerFactory<ResgatarPontos>(
    () => ResgatarPontos(
      pontosRepository: sl(),
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

  sl.registerFactory<RecuperarEnderecosDaPessoa>(
    () => RecuperarEnderecosDaPessoa(enderecosRepository: sl()),
  );

  sl.registerFactory<CriarEndereco>(
    () => CriarEndereco(enderecosRepository: sl()),
  );

  sl.registerFactory<SalvarEndereco>(
    () => SalvarEndereco(enderecosRepository: sl()),
  );

  sl.registerFactory<ExcluirEndereco>(
    () => ExcluirEndereco(enderecosRepository: sl()),
  );

  sl.registerFactory<CriarFuncionario>(
    () => CriarFuncionario(funcionariosRepository: sl()),
  );

  sl.registerFactory<SalvarFuncionario>(
    () => SalvarFuncionario(funcionariosRepository: sl()),
  );

  sl.registerFactory<ExcluirFuncionario>(
    () => ExcluirFuncionario(funcionariosRepository: sl()),
  );

  sl.registerFactory<RecuperarFuncionario>(
    () => RecuperarFuncionario(funcionariosRepository: sl()),
  );

  sl.registerFactory<RecuperarFuncionarios>(
    () => RecuperarFuncionarios(funcionariosRepository: sl()),
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

  sl.registerFactory<IEnderecosRepository>(
    () => EnderecosRepository(enderecosRemoteDataSource: sl()),
  );

  sl.registerFactory<IFuncionariosRepository>(
    () => FuncionariosRepository(funcionariosRemoteDataSource: sl()),
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

  sl.registerFactory<IEnderecosRemoteDataSource>(
    () => EnderecosRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IFuncionariosRemoteDataSource>(
    () => FuncionariosRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}
