import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';

class ExcluirReferenciaMidia {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  ExcluirReferenciaMidia({required this.referenciaMidiasRepository});

  Future<void> call({required int referenciaId, required int id}) {
    return referenciaMidiasRepository.excluirReferenciaMidia(
      referenciaId: referenciaId,
      id: id,
    );
  }
}
