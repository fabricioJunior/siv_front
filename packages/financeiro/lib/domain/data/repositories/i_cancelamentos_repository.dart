abstract class ICancelamentosRepository {
  Future<void> cancelarRomaneio({
    required int caixaId,
    required int idRomaneio,
    required String motivo,
  });
}