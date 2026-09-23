import 'dart:typed_data';

import 'package:precos/domain/models/importacao_tabela_de_preco.dart';

abstract class IImportacaoTabelaDePrecoRepository {
  Future<Uint8List> baixarTemplateCsv({required int tabelaDePrecoId});

  Future<ImportacaoTabelaDePreco> importarCsv({required String filePath});

  Future<ImportacaoTabelaDePreco> consultarImportacao(int id);
}
