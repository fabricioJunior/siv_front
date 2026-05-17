import 'package:financeiro/data.dart';

class CancelarRomaneio {
  final ICancelamentosRepository _repository;

  CancelarRomaneio({required ICancelamentosRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int idRomaneio,
    required String motivo,
  }) {
    return _repository.cancelarRomaneio(
      caixaId: caixaId,
      idRomaneio: idRomaneio,
      motivo: motivo,
    );
  }
}