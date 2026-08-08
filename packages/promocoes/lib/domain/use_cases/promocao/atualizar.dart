import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/domain/models/promocao.dart';

class AtualizarPromocao {
  final IPromocoesRepository _repository;

  AtualizarPromocao({required IPromocoesRepository repository})
      : _repository = repository;

  Future<Promocao> call(Promocao promocao) {
    return _repository.atualizarPromocao(promocao);
  }
}
