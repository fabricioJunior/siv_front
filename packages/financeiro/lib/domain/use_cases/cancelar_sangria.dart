import 'package:financeiro/data.dart';

class CancelarSangria {
  final ISangriasRepository _repository;

  CancelarSangria({required ISangriasRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int sangriaId,
    required String motivo,
  }) {
    return _repository.cancelarSangria(
      caixaId: caixaId,
      sangriaId: sangriaId,
      motivo: motivo,
    );
  }
}
