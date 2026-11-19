// Compressão de imagem pelo próprio navegador (só Flutter Web); nas demais plataformas devolve null.
export 'comprimir_imagem_nativa_io.dart' if (dart.library.js_interop) 'comprimir_imagem_nativa_web.dart';
