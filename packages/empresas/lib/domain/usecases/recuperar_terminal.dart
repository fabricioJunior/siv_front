import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/terminal.dart';

class RecuperarTerminal {
  final ITerminaisRepository _repository;

  RecuperarTerminal({required ITerminaisRepository repository})
    : _repository = repository;

  Future<Terminal?> call({required int empresaId, required int id}) {
    return _repository.recuperarTerminal(empresaId: empresaId, id: id);
  }
}
