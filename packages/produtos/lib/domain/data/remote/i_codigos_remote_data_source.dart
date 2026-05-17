import 'package:core/paginacao/paginacao.dart';
import 'package:produtos/domain/models/codigo.dart';

abstract class ICodigosRemoteDataSource {
  Future<Paginacao<Codigo>> buscarCodigos({
    required int pagina,
    required int limite,
    DateTime? ultimaAtualizacaoInicio,
    DateTime? ultimaAtualizacaoFim,
  });

  Future<int?> recuperarProdutoIdPorCodigoDeBarras(String codigoDeBarras);
}
