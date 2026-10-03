import 'package:empresas/domain/data/repositories/i_integracao_meta_repository.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';

class RecuperarIntegracaoMeta {
  final IIntegracaoMetaRepository _repository;

  RecuperarIntegracaoMeta({required IIntegracaoMetaRepository repository})
    : _repository = repository;

  Future<IntegracaoMeta> call(int empresaId) =>
      _repository.recuperar(empresaId);
}
