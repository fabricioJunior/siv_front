import 'package:comercial/domain/data/repositories/i_fidelidade_repository.dart';
import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';

class RecuperarOpcoesResgatePontos {
  final IFidelidadeRepository _repository;

  RecuperarOpcoesResgatePontos({required IFidelidadeRepository repository})
      : _repository = repository;

  Future<OpcoesResgatePontos> call({required int pessoaId}) {
    return _repository.recuperarOpcoesResgate(pessoaId: pessoaId);
  }
}
