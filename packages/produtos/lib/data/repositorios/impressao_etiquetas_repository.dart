import 'package:produtos/domain/data/repositorios/i_impressao_etiquetas_repository.dart';

class ImpressaoEtiquetasRepository implements IImpressaoEtiquetasRepository {
  @override
  Future<void> imprimirEtiquetas({required List<String> zpls}) async {
    // TODO: integrar com servico real de impressao de etiquetas.
  }
}
