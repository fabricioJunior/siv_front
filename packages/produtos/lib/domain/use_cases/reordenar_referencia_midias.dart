import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';

class ReordenarReferenciaMidias {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  ReordenarReferenciaMidias({required this.referenciaMidiasRepository});

  /// [ids] na ordem final; o backend marca a primeira como capa.
  Future<void> call({required int referenciaId, required List<int> ids}) {
    return referenciaMidiasRepository.reordenarReferenciaMidias(
      referenciaId: referenciaId,
      ids: ids,
    );
  }
}
