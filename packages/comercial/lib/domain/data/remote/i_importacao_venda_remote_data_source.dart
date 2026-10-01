import 'dart:typed_data';

import 'package:comercial/domain/models/importacao_venda.dart';

abstract class IImportacaoVendaRemoteDataSource {
  Future<Uint8List> baixarTemplateCsv();

  Future<ImportacaoVenda> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
    required int funcionarioId,
  });

  Future<ImportacaoVenda> consultarImportacao(int id);
}
