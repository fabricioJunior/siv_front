import 'dart:typed_data';

import 'package:produtos/domain/models/importacao_produto.dart';

abstract class IImportacaoProdutoRemoteDataSource {
  Future<Uint8List> baixarTemplateCsv({
    required ImportacaoProdutoVariante variante,
  });

  Future<ImportacaoProduto> importarCsv({
    required String filePath,
    required ImportacaoProdutoVariante variante,
  });

  Future<ImportacaoProduto> consultarImportacao(int id);
}
