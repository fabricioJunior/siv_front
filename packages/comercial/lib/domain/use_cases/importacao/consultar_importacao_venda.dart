import 'package:comercial/domain/data/repositories/i_importacao_venda_repository.dart';
import 'package:comercial/domain/models/importacao_venda.dart';

class ConsultarImportacaoVenda {
  final IImportacaoVendaRepository _repository;

  ConsultarImportacaoVenda({required IImportacaoVendaRepository repository})
      : _repository = repository;

  Future<ImportacaoVenda> call(int id) {
    return _repository.consultarImportacao(id);
  }
}
