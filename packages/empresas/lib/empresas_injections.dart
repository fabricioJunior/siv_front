import 'package:core/injecoes.dart';
import 'package:empresas/data/remote_data_sourcers/empresas_remote_data_source.dart';
import 'package:empresas/data/repositories/empresas_repository.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresas_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';
import 'package:empresas/domain/usecases/salvar_empresa.dart';
import 'package:empresas/presentation/blocs/empresa_bloc/empresa_bloc.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:empresas/use_cases.dart';

void resolverDependenciasEmpresas() {
  _remoteDataSourcers();
  _repositories();
  _useCases();
  _presentantion();
}

void _remoteDataSourcers() {
  sl.registerFactory<IEmpresasRemoteDataSource>(
    () => EmpresasRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<IEmpresasRepository>(
    () => EmpresasRepository(
      empresasRemoteDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<CriarEmpresa>(
    () => CriarEmpresa(
      sl(),
    ),
  );

  sl.registerFactory<RecuperarEmpresas>(
    () => RecuperarEmpresas(
      empresasRepository: sl(),
    ),
  );

  sl.registerFactory<RecuperarEmpresa>(
    () => RecuperarEmpresa(
      empresasRepository: sl(),
    ),
  );

  sl.registerFactory<SalvarEmpresa>(
    () => SalvarEmpresa(
      empresasRepository: sl(),
    ),
  );
}

void _presentantion() {
  sl.registerFactory<EmpresasBloc>(
    () => EmpresasBloc(sl()),
  );

  sl.registerFactory<EmpresaBloc>(
    () => EmpresaBloc(
      sl(),
      sl(),
      sl(),
    ),
  );
}
