import 'package:produtos/repositorios.dart';

class ExcluirEtiqueta {
  final IEtiquetasRepository _etiquetasRepository;

  ExcluirEtiqueta({required IEtiquetasRepository etiquetasRepository})
    : _etiquetasRepository = etiquetasRepository;

  Future<void> call(int id) {
    return _etiquetasRepository.excluirEtiqueta(id);
  }
}
