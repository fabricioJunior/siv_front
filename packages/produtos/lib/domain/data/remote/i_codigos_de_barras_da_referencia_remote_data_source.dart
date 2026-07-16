import 'package:produtos/domain/models/pagina_codigos_de_barras.dart';

abstract class ICodigosDeBarrasDaReferenciaRemoteDataSource {
  Future<PaginaCodigosDeBarras> listar({
    required int referenciaId,
    required int page,
    required int limit,
  });
}
