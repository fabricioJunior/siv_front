import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class BuscarComunicado {
  final IComunicadoRepository repository;

  BuscarComunicado({required this.repository});

  Future<Comunicado> call(int id) {
    return repository.buscarComunicado(id);
  }
}
