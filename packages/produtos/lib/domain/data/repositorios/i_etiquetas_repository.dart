import 'package:produtos/models.dart';

abstract class IEtiquetasRepository {
  Future<List<Etiqueta>> obterEtiquetas();

  Future<void> excluirEtiqueta(int id);

  Future<Etiqueta> criarEtiqueta({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  });
}
