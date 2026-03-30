import 'package:core/paginacao/paginacao.dart';
import 'package:produtos/domain/models/codigo.dart';

abstract class ICodigosRemoteDataSource {
  Future<Paginacao<Codigo>> buscarCodigos({
    required int pagina,
    required int limite,
  });

  Future<int?> recuperarProdutoIdPorCodigoDeBarras(String codigoDeBarras);
}
