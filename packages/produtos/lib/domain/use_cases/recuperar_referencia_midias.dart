import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';

import '../models/referencia_midia.dart';

class RecuperarReferenciaMidias {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  RecuperarReferenciaMidias({required this.referenciaMidiasRepository});

  Future<List<ReferenciaMidia>> call(int referenciaId) {
    return referenciaMidiasRepository.recuperarReferenciasMidias(referenciaId);
  }
}
