import 'package:produtos/domain/data/repositorios/i_importacao_produto_repository.dart';
import 'package:produtos/domain/models/importacao_produto.dart';

class ConsultarImportacaoProduto {
  final IImportacaoProdutoRepository _repository;

  ConsultarImportacaoProduto({required IImportacaoProdutoRepository repository})
      : _repository = repository;

  Future<ImportacaoProduto> call(int id) {
    return _repository.consultarImportacao(id);
  }
}
