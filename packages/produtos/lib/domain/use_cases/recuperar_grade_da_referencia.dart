import 'package:produtos/domain/data/repositorios/i_grade_da_referencia_repository.dart';
import 'package:produtos/models.dart';

class RecuperarGradeDaReferencia {
  final IGradeDaReferenciaRepository _gradeDaReferenciaRepository;

  RecuperarGradeDaReferencia({
    required IGradeDaReferenciaRepository gradeDaReferenciaRepository,
  }) : _gradeDaReferenciaRepository = gradeDaReferenciaRepository;

  Future<GradeDaReferencia> call({
    required int referenciaId,
    int? tabelaDePrecoId,
  }) {
    return _gradeDaReferenciaRepository.obterGrade(
      referenciaId: referenciaId,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
