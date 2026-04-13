import 'package:core/injecoes.dart';
import 'package:empresas/data/remote_data_sourcers/empresas_remote_data_source.dart';
import 'package:empresas/data/remote_data_sourcers/empresa_parametro_remote_data_source.dart';
import 'package:empresas/data/remote_data_sourcers/terminais_remote_data_source.dart';
import 'package:empresas/data/repositories/empresa_parametro_repository.dart';
import 'package:empresas/data/repositories/empresas_repository.dart';
import 'package:empresas/data/repositories/terminais_repository.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresa_parametro_remote_data_source.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresas_remote_data_source.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_terminais_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_empresa_parametro_repository.dart';
import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';
import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/presentation/blocs/empresa_parametros_bloc/empresa_parametros_bloc.dart';
import 'package:empresas/presentation/blocs/empresa_bloc/empresa_bloc.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:empresas/presentation/blocs/terminal_bloc/terminal_bloc.dart';
import 'package:empresas/presentation/blocs/terminais_bloc/terminais_bloc.dart';
import 'package:empresas/use_cases.dart';

void resolverDependenciasEmpresas() {
  _remoteDataSourcers();
  _repositories();
  _useCases();
  _presentantion();
}

void _remoteDataSourcers() {
  sl.registerFactory<IEmpresasRemoteDataSource>(
    () => EmpresasRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IEmpresaParametroRemoteDataSource>(
    () => EmpresaParametroRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ITerminaisRemoteDataSource>(
    () => TerminaisRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositories() {
  sl.registerFactory<IEmpresasRepository>(
    () => EmpresasRepository(empresasRemoteDataSource: sl()),
  );

  sl.registerFactory<IEmpresaParametroRepository>(
    () => EmpresaParametroRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<ITerminaisRepository>(
    () => TerminaisRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<CriarEmpresa>(() => CriarEmpresa(sl()));

  sl.registerFactory<RecuperarEmpresas>(
    () => RecuperarEmpresas(empresasRepository: sl()),
  );

  sl.registerFactory<RecuperarEmpresa>(
    () => RecuperarEmpresa(empresasRepository: sl()),
  );

  sl.registerFactory<SalvarEmpresa>(
    () => SalvarEmpresa(empresasRepository: sl()),
  );

  sl.registerFactory<RecuperarParametrosEmpresa>(
    () => RecuperarParametrosEmpresa(repository: sl()),
  );

  sl.registerFactory<AtualizarParametrosEmpresa>(
    () => AtualizarParametrosEmpresa(repository: sl()),
  );

  sl.registerFactory<CriarTerminal>(() => CriarTerminal(repository: sl()));

  sl.registerFactory<RecuperarTerminais>(
    () => RecuperarTerminais(repository: sl()),
  );

  sl.registerFactory<RecuperarTerminal>(
    () => RecuperarTerminal(repository: sl()),
  );

  sl.registerFactory<AtualizarTerminal>(
    () => AtualizarTerminal(repository: sl()),
  );

  sl.registerFactory<DesativarTerminal>(
    () => DesativarTerminal(repository: sl()),
  );
}

void _presentantion() {
  sl.registerFactory<EmpresasBloc>(() => EmpresasBloc(sl()));

  sl.registerFactory<EmpresaBloc>(() => EmpresaBloc(sl(), sl(), sl()));

  sl.registerFactory<EmpresaParametrosBloc>(
    () => EmpresaParametrosBloc(sl(), sl()),
  );

  sl.registerFactory<TerminaisBloc>(() => TerminaisBloc(sl(), sl()));

  sl.registerFactory<TerminalBloc>(() => TerminalBloc(sl(), sl(), sl()));
}
