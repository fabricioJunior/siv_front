import 'dart:typed_data';

import 'package:precos/domain/data/repositorios/i_importacao_tabela_de_preco_repository.dart';

class BaixarTemplateImportacaoTabelaDePreco {
  final IImportacaoTabelaDePrecoRepository _repository;

  BaixarTemplateImportacaoTabelaDePreco({
    required IImportacaoTabelaDePrecoRepository repository,
  }) : _repository = repository;

  Future<Uint8List> call({required int tabelaDePrecoId}) {
    return _repository.baixarTemplateCsv(tabelaDePrecoId: tabelaDePrecoId);
  }
}
