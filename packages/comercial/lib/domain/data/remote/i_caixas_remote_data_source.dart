abstract class IReceberRomaneioNoCaixaRemoteDataSource {
  Future<void> receberRomaneio({
    required int caixaId,
    required int romaneioId,
  });
}
