abstract class ICancelamentosRemoteDataSource {
  Future<void> cancelarRomaneio({
    required int idRomaneio,
    required String motivo,
    required int idCaixa,
  });

  Future<void> cancelarAdiantamento({
    required int idRomaneio,
    required String motivo,
    required int idCaixa,
  });
}
