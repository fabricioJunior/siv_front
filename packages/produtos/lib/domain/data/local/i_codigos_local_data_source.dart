import 'package:produtos/domain/models/codigo.dart';

abstract class ICodigosLocalDataSource {
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos);

  Future<Codigo?> recuperarCodigo(String codigo); 
  
  Future<Iterable<Codigo>> recuperarCodigosPorProdutoId(int produtoId);

  Future<Map<int, Iterable<Codigo>>> recuperarCodigosPorProdutoIds(
    Iterable<int> produtoIds,
  );
}
