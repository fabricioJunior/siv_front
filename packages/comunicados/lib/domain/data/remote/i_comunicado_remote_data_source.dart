import 'dart:typed_data';

import 'package:comunicados/domain/models/models.dart';

abstract class IComunicadoRemoteDataSource {
  Future<int> contarDestinatarios(FiltroDestinatarioComunicado filtro);

  Future<List<PreviewDestinatarioComunicado>> previewDestinatarios(
    FiltroDestinatarioComunicado filtro, {
    int limit = 20,
  });

  Future<String> enviarImagem(Uint8List bytes, String fileName);

  Future<Comunicado> criar({
    required String assunto,
    required String corpoHtml,
    bool? modoHtmlAvancado,
    required FiltroDestinatarioComunicado filtro,
  });

  Future<({List<Comunicado> items, int total})> listarComunicados({
    String? status,
    int pagina,
    int itemsPorPagina,
  });

  Future<Comunicado> buscarComunicado(int id);

  Future<({List<ComunicadoDestinatario> items, int total})>
  listarDestinatarios(
    int comunicadoId, {
    String? status,
    int pagina,
    int itemsPorPagina,
  });

  Future<ComunicadoDestinatario> reenviarDestinatario(
    int comunicadoId,
    int destinatarioId,
  );
}
