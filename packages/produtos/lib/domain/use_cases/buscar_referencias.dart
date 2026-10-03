import 'package:produtos/domain/data/repositorios/i_referencias_busca_repository.dart';
import 'package:produtos/domain/models/referencias_busca.dart';

/// Busca paginada de referências no servidor (nome/nº, categoria, pendências e ordenação) com o resumo dos chips.
class BuscarReferencias {
  final IReferenciasBuscaRepository _repository;

  BuscarReferencias({required IReferenciasBuscaRepository repository})
    : _repository = repository;

  Future<ReferenciasBuscaResultado> call({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    return _repository.buscar(
      busca: busca,
      categoriaId: categoriaId,
      semNcm: semNcm,
      semPeso: semPeso,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    );
  }
}
