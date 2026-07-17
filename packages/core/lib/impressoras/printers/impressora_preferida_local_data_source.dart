import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

abstract class IImpressoraPreferidaLocalDataSource {
  Future<String?> obterUltimaImpressora();
  Future<void> salvarUltimaImpressora(String nomeImpressora);
}

const String _nomeArquivo = 'impressora_preferida.txt';

// Persistencia simples em arquivo (mesmo padrao usado em
// DispositivoLocalDataSource) -- um unico valor (nome da ultima impressora
// usada) nao justifica uma collection Isar dedicada.
class ImpressoraPreferidaLocalDataSource
    implements IImpressoraPreferidaLocalDataSource {
  Future<File> _arquivo() async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    return File('${docsDir.path}/$_nomeArquivo');
  }

  @override
  Future<String?> obterUltimaImpressora() async {
    try {
      final arquivo = await _arquivo();
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
  Future<void> salvarUltimaImpressora(String nomeImpressora) async {
    try {
      final arquivo = await _arquivo();
      await arquivo.writeAsString(nomeImpressora);
    } catch (_) {
      // Falha ao persistir preferencia nao deve interromper a impressao.
    }
  }
}
