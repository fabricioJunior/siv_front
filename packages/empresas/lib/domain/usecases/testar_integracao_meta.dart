import 'package:empresas/domain/data/repositories/i_integracao_meta_repository.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';

class TestarIntegracaoMeta {
  final IIntegracaoMetaRepository _repository;

  TestarIntegracaoMeta({required IIntegracaoMetaRepository repository})
    : _repository = repository;

  Future<IntegracaoMetaTeste> call(int empresaId) =>
      _repository.testar(empresaId);
}
