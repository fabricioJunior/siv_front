import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class PreviewDestinatariosComunicado {
  final IComunicadoRepository repository;

  PreviewDestinatariosComunicado({required this.repository});

  Future<List<PreviewDestinatarioComunicado>> call(
    FiltroDestinatarioComunicado filtro, {
    int limit = 20,
  }) {
    return repository.previewDestinatarios(filtro, limit: limit);
  }
}
