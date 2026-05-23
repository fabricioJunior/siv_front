import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/sangria.dart';

class RecuperarSangria {
  final ISangriasRepository _repository;

  RecuperarSangria({required ISangriasRepository repository})
      : _repository = repository;

  Future<Sangria> call({
    required int caixaId,
    required int sangriaId,
  }) {
    return _repository.recuperarSangria(
      caixaId: caixaId,
      sangriaId: sangriaId,
    );
  }
}
