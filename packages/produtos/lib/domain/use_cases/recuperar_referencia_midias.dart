import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:collection/collection.dart';
import '../models/referencia_midia.dart';

class RecuperarReferenciaMidias {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  RecuperarReferenciaMidias({required this.referenciaMidiasRepository});

  Future<List<ReferenciaMidia>> call(int referenciaId) async {
    var result = List<ReferenciaMidia>.from(
      await referenciaMidiasRepository.recuperarReferenciasMidias(referenciaId),
    );
    var defaultMidia = result.firstWhereOrNull((midia) => midia.ePrincipal);
    if (defaultMidia != null) {
      result.remove(defaultMidia);
      result.insert(0, defaultMidia);
    }
    return result;
  }
}
