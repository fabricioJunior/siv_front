import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';

class DesativarTerminal {
  final ITerminaisRepository _repository;

  DesativarTerminal({required ITerminaisRepository repository})
    : _repository = repository;

  Future<void> call({required int empresaId, required int id}) {
    return _repository.desativarTerminal(empresaId: empresaId, id: id);
  }
}
