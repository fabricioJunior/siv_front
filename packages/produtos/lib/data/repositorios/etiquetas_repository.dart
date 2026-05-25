import 'package:produtos/domain/data/remote/i_etiquetas_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_etiquetas_repository.dart';
import 'package:produtos/models.dart';

class EtiquetasRepository implements IEtiquetasRepository {
  final IEtiquetasRemoteDataSource etiquetasRemoteDataSource;

  EtiquetasRepository({required this.etiquetasRemoteDataSource});

  @override
  Future<List<Etiqueta>> obterEtiquetas() {
    return etiquetasRemoteDataSource.fetchEtiquetas();
  }

  @override
  Future<Etiqueta> criarEtiqueta({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  }) {
    return etiquetasRemoteDataSource.createEtiqueta(
      nome: nome,
      altura: altura,
      largura: largura,
      dpi: dpi,
      elementos: elementos,
      vias: vias,
    );
  }
}
