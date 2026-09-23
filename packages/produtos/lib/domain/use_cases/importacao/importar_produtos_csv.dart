import 'package:produtos/domain/data/repositorios/i_importacao_produto_repository.dart';
import 'package:produtos/domain/models/importacao_produto.dart';

class ImportarProdutosCsv {
  final IImportacaoProdutoRepository _repository;

  ImportarProdutosCsv({required IImportacaoProdutoRepository repository})
      : _repository = repository;

  Future<ImportacaoProduto> call({
    required String filePath,
    required ImportacaoProdutoVariante variante,
  }) {
    return _repository.importarCsv(filePath: filePath, variante: variante);
  }
}
