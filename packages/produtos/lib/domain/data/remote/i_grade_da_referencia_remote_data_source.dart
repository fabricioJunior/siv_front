import 'package:produtos/models.dart';

abstract class IGradeDaReferenciaRemoteDataSource {
  Future<GradeDaReferencia> fetchGrade({
    required int referenciaId,
    int? tabelaDePrecoId,
  });
}
