import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/terminal.dart';

class RecuperarTerminais {
  final ITerminaisRepository _repository;

  RecuperarTerminais({required ITerminaisRepository repository})
    : _repository = repository;

  Future<List<Terminal>> call({
    required int empresaId,
    String? nome,
    bool? inativo,
  }) {
    return _repository.recuperarTerminais(
      empresaId: empresaId,
      nome: nome,
      inativo: inativo,
    );
  }
}
