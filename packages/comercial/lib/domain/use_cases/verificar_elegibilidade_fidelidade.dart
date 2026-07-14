import 'package:comercial/domain/data/repositories/i_fidelidade_repository.dart';

class VerificarElegibilidadeFidelidade {
  final IFidelidadeRepository _repository;

  VerificarElegibilidadeFidelidade({required IFidelidadeRepository repository})
      : _repository = repository;

  Future<bool> call({required int pessoaId}) {
    return _repository.verificarElegibilidade(pessoaId: pessoaId);
  }
}
