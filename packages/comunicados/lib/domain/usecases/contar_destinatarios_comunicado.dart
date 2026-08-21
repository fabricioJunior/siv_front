import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class ContarDestinatariosComunicado {
  final IComunicadoRepository repository;

  ContarDestinatariosComunicado({required this.repository});

  Future<int> call(FiltroDestinatarioComunicado filtro) {
    return repository.contarDestinatarios(filtro);
  }
}
