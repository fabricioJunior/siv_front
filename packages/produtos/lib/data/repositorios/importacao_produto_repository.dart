import 'dart:typed_data';

import 'package:produtos/domain/data/remote/i_importacao_produto_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_importacao_produto_repository.dart';
import 'package:produtos/domain/models/importacao_produto.dart';

class ImportacaoProdutoRepository implements IImportacaoProdutoRepository {
  final IImportacaoProdutoRemoteDataSource remoteDataSource;

  ImportacaoProdutoRepository({required this.remoteDataSource});

  @override
  Future<Uint8List> baixarTemplateCsv({
    required ImportacaoProdutoVariante variante,
  }) {
    return remoteDataSource.baixarTemplateCsv(variante: variante);
  }

  @override
  Future<ImportacaoProduto> importarCsv({
    required String filePath,
    required ImportacaoProdutoVariante variante,
  }) {
    return remoteDataSource.importarCsv(filePath: filePath, variante: variante);
  }

  @override
  Future<ImportacaoProduto> consultarImportacao(int id) {
    return remoteDataSource.consultarImportacao(id);
  }
}
