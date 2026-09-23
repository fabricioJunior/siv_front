import 'dart:typed_data';

import 'package:precos/domain/data/remote/i_importacao_tabela_de_preco_remote_data_source.dart';
import 'package:precos/domain/data/repositorios/i_importacao_tabela_de_preco_repository.dart';
import 'package:precos/domain/models/importacao_tabela_de_preco.dart';

class ImportacaoTabelaDePrecoRepository
    implements IImportacaoTabelaDePrecoRepository {
  final IImportacaoTabelaDePrecoRemoteDataSource remoteDataSource;

  ImportacaoTabelaDePrecoRepository({required this.remoteDataSource});

  @override
  Future<Uint8List> baixarTemplateCsv({required int tabelaDePrecoId}) {
    return remoteDataSource.baixarTemplateCsv(
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }

  @override
  Future<ImportacaoTabelaDePreco> importarCsv({required String filePath}) {
    return remoteDataSource.importarCsv(filePath: filePath);
  }

  @override
  Future<ImportacaoTabelaDePreco> consultarImportacao(int id) {
    return remoteDataSource.consultarImportacao(id);
  }
}
