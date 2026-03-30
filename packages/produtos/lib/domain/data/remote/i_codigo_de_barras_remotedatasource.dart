abstract class ICodigoDeBarrasRemoteDatasource {
  Future<void> salvarCodigo({
    required int produtoId,
    required String codigoDeBarras,
  });

  Future<void> deletarCodigo({
    required int produtoId,
    required String codigoDeBarras,
  });
}
