import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class EditarEtiqueta {
  final IEtiquetasRepository _etiquetasRepository;

  EditarEtiqueta({required IEtiquetasRepository etiquetasRepository})
    : _etiquetasRepository = etiquetasRepository;

  Future<Etiqueta> call({
    required int id,
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  }) {
    return _etiquetasRepository.editarEtiqueta(
      id: id,
      nome: nome,
      altura: altura,
      largura: largura,
      dpi: dpi,
      elementos: elementos,
      vias: vias,
    );
  }
}
