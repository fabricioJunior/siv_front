// Download de bytes pelo navegador (só Flutter Web). Nas demais plataformas não é chamado.
export 'download_arquivo_io.dart' if (dart.library.js_interop) 'download_arquivo_web.dart';
