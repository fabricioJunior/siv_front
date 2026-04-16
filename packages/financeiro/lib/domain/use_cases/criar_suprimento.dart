import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/suprimento.dart';

class CriarSuprimento {
  final ISuprimentosRepository _repository;

  CriarSuprimento({required ISuprimentosRepository repository})
      : _repository = repository;

  Future<Suprimento> call({
    required int caixaId,
    required double valor,
    required String descricao,
  }) {
    return _repository.criarSuprimento(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
    );
  }
}
