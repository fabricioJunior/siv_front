import 'package:empresas/domain/entities/integracao_meta.dart';

abstract class IIntegracaoMetaRemoteDataSource {
  Future<IntegracaoMeta> recuperar(int empresaId);

  Future<IntegracaoMeta> salvar(
    int empresaId,
    IntegracaoMetaAlteracoes alteracoes,
  );

  Future<IntegracaoMetaTeste> testar(int empresaId);
}
