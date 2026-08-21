import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class ListarDestinatariosComunicado {
  final IComunicadoRepository repository;

  ListarDestinatariosComunicado({required this.repository});

  Future<({List<ComunicadoDestinatario> items, int total})> call(
    int comunicadoId, {
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) {
    return repository.listarDestinatarios(
      comunicadoId,
      status: status,
      pagina: pagina,
      itemsPorPagina: itemsPorPagina,
    );
  }
}
