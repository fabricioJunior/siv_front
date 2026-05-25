import 'package:core/paginacao/paginacao.dart';

abstract class ICodigosRepository {
  Future<void> criarCodigo({required int produtoId, required String codigo});

  Future<void> deletarCodigo({required int produtoId, required String codigo});

  Future<String?> recuperarCodigoPorProdutoId(int produtoId);

  Stream<Paginacao> sincronizarCodigos();
}
