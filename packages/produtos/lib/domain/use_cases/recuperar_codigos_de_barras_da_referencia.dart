import 'package:produtos/domain/data/repositorios/i_codigos_de_barras_da_referencia_repository.dart';
import 'package:produtos/domain/models/pagina_codigos_de_barras.dart';

class RecuperarCodigosDeBarrasDaReferencia {
  final ICodigosDeBarrasDaReferenciaRepository _repository;

  RecuperarCodigosDeBarrasDaReferencia({
    required ICodigosDeBarrasDaReferenciaRepository repository,
  }) : _repository = repository;

  Future<PaginaCodigosDeBarras> call({
    required int referenciaId,
    int page = 1,
    int limit = 100,
  }) {
    return _repository.listar(
      referenciaId: referenciaId,
      page: page,
      limit: limit,
    );
  }
}
