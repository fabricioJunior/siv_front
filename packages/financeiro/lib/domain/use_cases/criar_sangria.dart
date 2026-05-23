import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/sangria.dart';

class CriarSangria {
  final ISangriasRepository _repository;

  CriarSangria({required ISangriasRepository repository})
      : _repository = repository;

  Future<Sangria> call({
    required int caixaId,
    required double valor,
    required String descricao,
    required String origem,
  }) {
    return _repository.criarSangria(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
      origem: origem,
    );
  }
}
