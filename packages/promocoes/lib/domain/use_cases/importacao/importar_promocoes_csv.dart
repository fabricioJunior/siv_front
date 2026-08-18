import 'package:promocoes/domain/data/repositories/i_importacao_promocoes_repository.dart';
import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';

class ImportarPromocoesCsv {
  final IImportacaoPromocoesRepository _repository;

  ImportarPromocoesCsv({required IImportacaoPromocoesRepository repository})
      : _repository = repository;

  Future<ImportacaoPromocao> call({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    PromocaoCanal? canal,
  }) {
    return _repository.importarCsv(
      filePath: filePath,
      nome: nome,
      dataInicio: dataInicio,
      dataFim: dataFim,
      canal: canal,
    );
  }
}
