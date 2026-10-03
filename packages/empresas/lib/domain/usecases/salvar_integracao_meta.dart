import 'package:empresas/domain/data/repositories/i_integracao_meta_repository.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';

class SalvarIntegracaoMeta {
  final IIntegracaoMetaRepository _repository;

  SalvarIntegracaoMeta({required IIntegracaoMetaRepository repository})
    : _repository = repository;

  Future<IntegracaoMeta> call(
    int empresaId,
    IntegracaoMetaAlteracoes alteracoes,
  ) => _repository.salvar(empresaId, alteracoes);
}
