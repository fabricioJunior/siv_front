import 'dart:typed_data';

import 'package:promocoes/domain/data/repositories/i_importacao_promocoes_repository.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

class BaixarTemplatePromocoesCsv {
  final IImportacaoPromocoesRepository _repository;

  BaixarTemplatePromocoesCsv({required IImportacaoPromocoesRepository repository})
      : _repository = repository;

  Future<Uint8List> call({required TipoDesconto tipoDesconto}) {
    return _repository.baixarTemplateCsv(tipoDesconto: tipoDesconto);
  }
}
