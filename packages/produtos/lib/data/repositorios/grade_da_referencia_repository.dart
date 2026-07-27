import 'package:produtos/domain/data/remote/i_grade_da_referencia_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_grade_da_referencia_repository.dart';
import 'package:produtos/models.dart';

class GradeDaReferenciaRepository implements IGradeDaReferenciaRepository {
  final IGradeDaReferenciaRemoteDataSource gradeDaReferenciaRemoteDataSource;

  GradeDaReferenciaRepository({
    required this.gradeDaReferenciaRemoteDataSource,
  });

  @override
  Future<GradeDaReferencia> obterGrade({
    required int referenciaId,
    int? tabelaDePrecoId,
  }) {
    return gradeDaReferenciaRemoteDataSource.fetchGrade(
      referenciaId: referenciaId,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
