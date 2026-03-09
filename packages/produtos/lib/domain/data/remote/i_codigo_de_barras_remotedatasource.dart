abstract class ICodigoDeBarrasRemoteDatasource {
  Future<void> salvarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  });

  Future<void> deletarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  });
}
