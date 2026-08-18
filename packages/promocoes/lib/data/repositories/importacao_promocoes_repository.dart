import 'dart:typed_data';

import 'package:promocoes/domain/data/remote/i_importacao_promocoes_remote_data_source.dart';
import 'package:promocoes/domain/data/repositories/i_importacao_promocoes_repository.dart';
import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';

class ImportacaoPromocoesRepository implements IImportacaoPromocoesRepository {
  final IImportacaoPromocoesRemoteDataSource remoteDataSource;

  ImportacaoPromocoesRepository({required this.remoteDataSource});

  @override
  Future<Uint8List> baixarTemplateCsv() {
    return remoteDataSource.baixarTemplateCsv();
  }

  @override
  Future<ImportacaoPromocao> importarCsv({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    PromocaoCanal? canal,
  }) {
    return remoteDataSource.importarCsv(
      filePath: filePath,
      nome: nome,
      dataInicio: dataInicio,
      dataFim: dataFim,
      canal: canal,
    );
  }

  @override
  Future<ImportacaoPromocao> consultarImportacao(int id) {
    return remoteDataSource.consultarImportacao(id);
  }
}
