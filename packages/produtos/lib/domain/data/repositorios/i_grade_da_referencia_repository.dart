import 'package:produtos/models.dart';

abstract class IGradeDaReferenciaRepository {
  Future<GradeDaReferencia> obterGrade({
    required int referenciaId,
    int? tabelaDePrecoId,
  });
}
