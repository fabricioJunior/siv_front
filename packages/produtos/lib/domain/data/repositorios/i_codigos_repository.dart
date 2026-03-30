import 'package:core/paginacao/paginacao.dart';

abstract class ICodigosRepository {
  Future<void> criarCodigo({required int produtoId, required String codigo});

  Future<void> deletarCodigo({required int produtoId, required String codigo});

  Stream<Paginacao> sincronizarCodigos();
}
