import 'dart:typed_data';

import 'package:importacao/domain/models/importacao_guiada.dart';

abstract class IImportacaoRemoteDataSource {
  /// Última importação de cada tipo da empresa (sem o resultado detalhado).
  Future<List<ImportacaoGuiada>> listarUltimas();

  /// Importação com o resultado detalhado (rejeições).
  Future<ImportacaoGuiada> consultar(int id);

  Future<Uint8List> baixarModelo(
    ImportacaoEtapa etapa, {
    Map<String, String> query = const {},
  });

  /// Amostra do que já está no sistema para a etapa (`tabelaDePrecoId` só
  /// na etapa de preços).
  Future<ImportacaoPrevia> previa(
    ImportacaoEtapa etapa, {
    int? tabelaDePrecoId,
  });

  /// Sobe o CSV; o servidor responde na hora com a importação pendente e
  /// processa em segundo plano.
  Future<ImportacaoGuiada> enviar(
    ImportacaoEtapa etapa, {
    required Uint8List bytes,
    required String nomeArquivo,
    Map<String, String> parametros = const {},
  });
}
