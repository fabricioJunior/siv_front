import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/terminal.dart';

class CriarTerminal {
  final ITerminaisRepository _repository;

  CriarTerminal({required ITerminaisRepository repository})
    : _repository = repository;

  Future<Terminal> call({required int empresaId, required String nome}) {
    return _repository.criarTerminal(empresaId: empresaId, nome: nome);
  }
}
