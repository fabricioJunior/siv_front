import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class ListarComunicados {
  final IComunicadoRepository repository;

  ListarComunicados({required this.repository});

  Future<({List<Comunicado> items, int total})> call({
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) {
    return repository.listarComunicados(
      status: status,
      pagina: pagina,
      itemsPorPagina: itemsPorPagina,
    );
  }
}
