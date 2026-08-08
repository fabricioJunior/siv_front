import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/domain/models/promocao.dart';

class CriarPromocao {
  final IPromocoesRepository _repository;

  CriarPromocao({required IPromocoesRepository repository})
      : _repository = repository;

  Future<Promocao> call(Promocao promocao) {
    return _repository.criarPromocao(promocao);
  }
}
