import 'package:empresas/domain/data/remote_data_sourcers/i_integracao_meta_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_integracao_meta_repository.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';

class IntegracaoMetaRepository implements IIntegracaoMetaRepository {
  final IIntegracaoMetaRemoteDataSource remoteDataSource;

  IntegracaoMetaRepository({required this.remoteDataSource});

  @override
  Future<IntegracaoMeta> recuperar(int empresaId) =>
      remoteDataSource.recuperar(empresaId);

  @override
  Future<IntegracaoMeta> salvar(
    int empresaId,
    IntegracaoMetaAlteracoes alteracoes,
  ) => remoteDataSource.salvar(empresaId, alteracoes);

  @override
  Future<IntegracaoMetaTeste> testar(int empresaId) =>
      remoteDataSource.testar(empresaId);
}
