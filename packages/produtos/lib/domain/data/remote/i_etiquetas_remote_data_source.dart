import 'package:produtos/models.dart';

abstract class IEtiquetasRemoteDataSource {
  Future<List<Etiqueta>> fetchEtiquetas();

  Future<Etiqueta> createEtiqueta({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  });
}
