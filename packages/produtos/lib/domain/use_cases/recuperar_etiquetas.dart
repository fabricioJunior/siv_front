import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarEtiquetas {
  final IEtiquetasRepository _etiquetasRepository;

  RecuperarEtiquetas({required IEtiquetasRepository etiquetasRepository})
    : _etiquetasRepository = etiquetasRepository;

  Future<List<Etiqueta>> call() async {
    final etiquetas = await _etiquetasRepository.obterEtiquetas();
    etiquetas.sort(
      (a, b) => b.id != null && a.id != null
          ? (b.id!).compareTo(a.id!)
          : a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );
    return etiquetas;
  }
}
