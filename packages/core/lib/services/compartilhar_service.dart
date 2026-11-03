import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ArquivoParaCompartilhar {
  final String nome;
  final Uint8List bytes;

  const ArquivoParaCompartilhar({required this.nome, required this.bytes});
}

/// Wrapper fino sobre `share_plus` e download de bytes por URL.
class CompartilharService {
  /// Share nativo com arquivos: mobile e web. No desktop o chamador baixa os arquivos.
  bool get suportaCompartilharArquivos =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<Uint8List> baixar(String url) async {
    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao baixar arquivo: ${resposta.statusCode}');
    }
    return resposta.bodyBytes;
  }

  /// No iOS o share não pode ter `await` antes: pré-carregue os bytes.
  Future<void> compartilhar({
    required List<ArquivoParaCompartilhar> arquivos,
    required String texto,
  }) {
    return Share.shareXFiles([
      for (final a in arquivos)
        XFile.fromData(a.bytes, name: a.nome, mimeType: 'image/jpeg'),
    ], text: texto);
  }
}
