import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/models/cupom.dart';

class RecuperarCupons {
  final ICuponsRepository _repository;

  RecuperarCupons({required ICuponsRepository repository})
      : _repository = repository;

  Future<List<Cupom>> call({String? codigo, bool? ativa, bool? vigente}) {
    return _repository.recuperarCupons(
      codigo: codigo,
      ativa: ativa,
      vigente: vigente,
    );
  }
}
