import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/domain/models/promocao.dart';

class RecuperarPromocao {
  final IPromocoesRepository _repository;

  RecuperarPromocao({required IPromocoesRepository repository})
      : _repository = repository;

  Future<Promocao?> call(int id) {
    return _repository.recuperarPromocao(id);
  }
}
