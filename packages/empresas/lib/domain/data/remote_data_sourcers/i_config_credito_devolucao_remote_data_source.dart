import 'package:empresas/domain/entities/config_credito_devolucao.dart';

abstract class IConfigCreditoDevolucaoRemoteDataSource {
  Future<ConfigCreditoDevolucao> recuperar(int empresaId);

  Future<ConfigCreditoDevolucao> salvar(
    int empresaId,
    ConfigCreditoDevolucao config,
  );
}
