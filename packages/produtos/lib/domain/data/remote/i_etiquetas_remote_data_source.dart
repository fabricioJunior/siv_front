import 'package:produtos/models.dart';

abstract class IEtiquetasRemoteDataSource {
  Future<List<Etiqueta>> fetchEtiquetas();

  Future<void> excluirEtiqueta(int id);

  Future<Etiqueta> createEtiqueta({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  });

  Future<Etiqueta> editarEtiqueta({
    required int id,
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  });
}
