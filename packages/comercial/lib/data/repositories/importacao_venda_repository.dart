import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_importacao_venda_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_importacao_venda_repository.dart';
import 'package:comercial/domain/models/importacao_venda.dart';

class ImportacaoVendaRepository implements IImportacaoVendaRepository {
  final IImportacaoVendaRemoteDataSource remoteDataSource;

  ImportacaoVendaRepository({required this.remoteDataSource});

  @override
  Future<Uint8List> baixarTemplateCsv() {
    return remoteDataSource.baixarTemplateCsv();
  }

  @override
  Future<ImportacaoVenda> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
    required int funcionarioId,
  }) {
    return remoteDataSource.importarCsv(
      filePath: filePath,
      tabelaDePrecoId: tabelaDePrecoId,
      funcionarioId: funcionarioId,
    );
  }

  @override
  Future<ImportacaoVenda> consultarImportacao(int id) {
    return remoteDataSource.consultarImportacao(id);
  }
}
