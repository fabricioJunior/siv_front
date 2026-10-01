import 'package:comercial/domain/data/repositories/i_importacao_venda_repository.dart';
import 'package:comercial/domain/models/importacao_venda.dart';

class ImportarVendasCsv {
  final IImportacaoVendaRepository _repository;

  ImportarVendasCsv({required IImportacaoVendaRepository repository})
      : _repository = repository;

  Future<ImportacaoVenda> call({
    required String filePath,
    required int tabelaDePrecoId,
    required int funcionarioId,
  }) {
    return _repository.importarCsv(
      filePath: filePath,
      tabelaDePrecoId: tabelaDePrecoId,
      funcionarioId: funcionarioId,
    );
  }
}
