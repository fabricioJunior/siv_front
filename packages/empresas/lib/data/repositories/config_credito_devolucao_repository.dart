import 'package:empresas/domain/data/remote_data_sourcers/i_config_credito_devolucao_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_config_credito_devolucao_repository.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';

class ConfigCreditoDevolucaoRepository
    implements IConfigCreditoDevolucaoRepository {
  final IConfigCreditoDevolucaoRemoteDataSource remoteDataSource;

  ConfigCreditoDevolucaoRepository({required this.remoteDataSource});

  @override
  Future<ConfigCreditoDevolucao> recuperar(int empresaId) =>
      remoteDataSource.recuperar(empresaId);

  @override
  Future<ConfigCreditoDevolucao> salvar(
    int empresaId,
    ConfigCreditoDevolucao config,
  ) =>
      remoteDataSource.salvar(empresaId, config);
}
