import 'package:produtos/domain/data/repositorios/i_impressao_etiquetas_repository.dart';

class ImprimirEtiquetas {
  final IImpressaoEtiquetasRepository _impressaoEtiquetasRepository;

  ImprimirEtiquetas({
    required IImpressaoEtiquetasRepository impressaoEtiquetasRepository,
  }) : _impressaoEtiquetasRepository = impressaoEtiquetasRepository;

  Future<void> call({required List<String> zpls}) {
    return _impressaoEtiquetasRepository.imprimirEtiquetas(zpls: zpls);
  }
}
