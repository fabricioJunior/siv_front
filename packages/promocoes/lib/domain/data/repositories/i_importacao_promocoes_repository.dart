import 'dart:typed_data';

import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';

abstract class IImportacaoPromocoesRepository {
  Future<Uint8List> baixarTemplateCsv();

  Future<ImportacaoPromocao> importarCsv({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    PromocaoCanal? canal,
  });

  Future<ImportacaoPromocao> consultarImportacao(int id);
}
