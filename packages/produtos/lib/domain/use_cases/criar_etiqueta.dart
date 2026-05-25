import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarEtiqueta {
  final IEtiquetasRepository _etiquetasRepository;

  CriarEtiqueta({required IEtiquetasRepository etiquetasRepository})
    : _etiquetasRepository = etiquetasRepository;

  Future<Etiqueta> call({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  }) {
    return _etiquetasRepository.criarEtiqueta(
      nome: nome,
      altura: altura,
      largura: largura,
      dpi: dpi,
      elementos: elementos,
      vias: vias,
    );
  }
}
