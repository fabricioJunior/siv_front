import 'dart:typed_data';

import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

abstract class IImportacaoPromocoesRemoteDataSource {
  Future<Uint8List> baixarTemplateCsv({required TipoDesconto tipoDesconto});

  Future<ImportacaoPromocao> importarCsv({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoDesconto tipoDesconto,
    PromocaoCanal? canal,
  });

  Future<ImportacaoPromocao> consultarImportacao(int id);
}
