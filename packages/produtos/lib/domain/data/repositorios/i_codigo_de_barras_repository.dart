abstract class ICodigoDeBarrasRepository {
  Future<void> criarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  });

  Future<void> deletarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  });
}
