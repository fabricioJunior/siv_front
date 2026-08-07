import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class ObterRastreioEntrega {
  final IIntegracaoEntregaRepository _repository;

  ObterRastreioEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<List<RastreioEntrega>> call(int id) => _repository.getRastreio(id);
}
