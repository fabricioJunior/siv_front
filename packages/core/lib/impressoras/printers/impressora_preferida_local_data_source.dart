import 'dart:io';

import 'package:core/impressoras/printers/tipo_impressora.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

abstract class IImpressoraPreferidaLocalDataSource {
  Future<String?> obterUltimaImpressora(TipoImpressora tipo);
  Future<void> salvarUltimaImpressora(TipoImpressora tipo, String nomeImpressora);
}

// Persistencia simples em arquivo (mesmo padrao usado em
// DispositivoLocalDataSource) -- um unico valor (nome da ultima impressora
// usada) nao justifica uma collection Isar dedicada. Um arquivo por
// TipoImpressora, pois etiqueta e documento (nota fiscal/romaneio) podem
// usar impressoras fisicas diferentes.
class ImpressoraPreferidaLocalDataSource
    implements IImpressoraPreferidaLocalDataSource {
  Future<File> _arquivo(TipoImpressora tipo) async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    return File('${docsDir.path}/${tipo.nomeArquivoPreferencia}');
  }

  @override
  Future<String?> obterUltimaImpressora(TipoImpressora tipo) async {
    try {
      final arquivo = await _arquivo(tipo);
      if (!arquivo.existsSync()) {
        return null;
      }
      final conteudo = await arquivo.readAsString();
      return conteudo.trim().isEmpty ? null : conteudo.trim();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> salvarUltimaImpressora(
    TipoImpressora tipo,
    String nomeImpressora,
  ) async {
    try {
      final arquivo = await _arquivo(tipo);
      await arquivo.writeAsString(nomeImpressora);
    } catch (_) {
      // Falha ao persistir preferencia nao deve interromper a impressao.
    }
  }
}
