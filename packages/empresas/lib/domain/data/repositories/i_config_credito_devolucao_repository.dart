import 'package:empresas/domain/entities/config_credito_devolucao.dart';

abstract class IConfigCreditoDevolucaoRepository {
  Future<ConfigCreditoDevolucao> recuperar(int empresaId);

  Future<ConfigCreditoDevolucao> salvar(
    int empresaId,
    ConfigCreditoDevolucao config,
  );
}
