import 'package:promocoes/domain/data/repositories/i_importacao_promocoes_repository.dart';
import 'package:promocoes/domain/models/importacao_promocao.dart';

class ConsultarImportacaoPromocao {
  final IImportacaoPromocoesRepository _repository;

  ConsultarImportacaoPromocao({required IImportacaoPromocoesRepository repository})
      : _repository = repository;

  Future<ImportacaoPromocao> call(int id) {
    return _repository.consultarImportacao(id);
  }
}
