import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:collection/collection.dart';
import '../models/referencia_midia.dart';

class RecuperarReferenciaMidias {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  RecuperarReferenciaMidias({required this.referenciaMidiasRepository});

  /// Por padrão devolve só as fotos do site: a foto do fornecedor é de uso
  /// interno e nunca pode aparecer na galeria que vai para a vitrine.
  Future<List<ReferenciaMidia>> call(
    int referenciaId, {
    bool doFornecedor = false,
  }) async {
    var result = List<ReferenciaMidia>.from(
      (await referenciaMidiasRepository.recuperarReferenciasMidias(
        referenciaId,
      )).where((midia) => midia.doFornecedor == doFornecedor),
    );
    var defaultMidia = result.firstWhereOrNull((midia) => midia.ePrincipal);
    if (defaultMidia != null) {
      result.remove(defaultMidia);
      result.insert(0, defaultMidia);
    }
    return result;
  }
}
