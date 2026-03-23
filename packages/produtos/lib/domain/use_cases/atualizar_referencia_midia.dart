import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/domain/models/referencia_midia.dart';

class AtualizarReferenciaMidia {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  AtualizarReferenciaMidia({required this.referenciaMidiasRepository});

  Future<void> call(ReferenciaMidia referenciaMidia) {
    return referenciaMidiasRepository.atualizarReferenciaMidia(referenciaMidia);
  }
}
