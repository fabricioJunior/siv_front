import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/terminal.dart';

class AtualizarTerminal {
  final ITerminaisRepository _repository;

  AtualizarTerminal({required ITerminaisRepository repository})
    : _repository = repository;

  Future<Terminal> call({
    required int empresaId,
    required int id,
    required String nome,
  }) {
    return _repository.atualizarTerminal(
      empresaId: empresaId,
      id: id,
      nome: nome,
    );
  }
}
