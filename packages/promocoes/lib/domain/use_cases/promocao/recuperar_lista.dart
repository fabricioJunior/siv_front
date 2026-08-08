import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/domain/models/promocao.dart';

class RecuperarPromocoes {
  final IPromocoesRepository _repository;

  RecuperarPromocoes({required IPromocoesRepository repository})
      : _repository = repository;

  Future<List<Promocao>> call({String? nome, bool? ativa, bool? vigente}) {
    return _repository.recuperarPromocoes(
      nome: nome,
      ativa: ativa,
      vigente: vigente,
    );
  }
}
