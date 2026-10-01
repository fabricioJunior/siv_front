import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Dispara o download de [bytes] como [nomeArquivo] (blob + `<a download>`).
void baixarNoNavegador(Uint8List bytes, String nomeArquivo) {
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final ancora = web.HTMLAnchorElement()
    ..href = url
    ..download = nomeArquivo
    ..style.display = 'none';
  web.document.body!.append(ancora);
  ancora.click();
  ancora.remove();
  web.URL.revokeObjectURL(url);
}
