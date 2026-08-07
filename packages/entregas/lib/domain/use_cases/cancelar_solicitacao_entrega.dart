import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class CancelarSolicitacaoEntrega {
  final IIntegracaoEntregaRepository _repository;

  CancelarSolicitacaoEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<SolicitacaoEntrega> call(int id, {int? motivoId}) =>
      _repository.cancelar(id, motivoId: motivoId);
}
