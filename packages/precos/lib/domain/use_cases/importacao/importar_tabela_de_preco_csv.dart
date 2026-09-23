import 'package:precos/domain/data/repositorios/i_importacao_tabela_de_preco_repository.dart';
import 'package:precos/domain/models/importacao_tabela_de_preco.dart';

class ImportarTabelaDePrecoCsv {
  final IImportacaoTabelaDePrecoRepository _repository;

  ImportarTabelaDePrecoCsv({
    required IImportacaoTabelaDePrecoRepository repository,
  }) : _repository = repository;

  Future<ImportacaoTabelaDePreco> call({required String filePath}) {
    return _repository.importarCsv(filePath: filePath);
  }
}
