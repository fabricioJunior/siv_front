import 'package:precos/domain/data/repositorios/i_importacao_tabela_de_preco_repository.dart';
import 'package:precos/domain/models/importacao_tabela_de_preco.dart';

class ConsultarImportacaoTabelaDePreco {
  final IImportacaoTabelaDePrecoRepository _repository;

  ConsultarImportacaoTabelaDePreco({
    required IImportacaoTabelaDePrecoRepository repository,
  }) : _repository = repository;

  Future<ImportacaoTabelaDePreco> call(int id) {
    return _repository.consultarImportacao(id);
  }
}
