import 'dart:typed_data';

import 'package:produtos/domain/data/repositorios/i_importacao_produto_repository.dart';
import 'package:produtos/domain/models/importacao_produto.dart';

class BaixarTemplateImportacaoProdutos {
  final IImportacaoProdutoRepository _repository;

  BaixarTemplateImportacaoProdutos({
    required IImportacaoProdutoRepository repository,
  }) : _repository = repository;

  Future<Uint8List> call({required ImportacaoProdutoVariante variante}) {
    return _repository.baixarTemplateCsv(variante: variante);
  }
}
