import 'dart:io';

import 'package:comunicados/domain/data/remote/i_comunicado_remote_data_source.dart';
import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class ComunicadoRepository implements IComunicadoRepository {
  final IComunicadoRemoteDataSource remoteDataSource;

  ComunicadoRepository({required this.remoteDataSource});

  @override
  Future<int> contarDestinatarios(FiltroDestinatarioComunicado filtro) {
    return remoteDataSource.contarDestinatarios(filtro);
  }

  @override
  Future<List<PreviewDestinatarioComunicado>> previewDestinatarios(
    FiltroDestinatarioComunicado filtro, {
    int limit = 20,
  }) {
    return remoteDataSource.previewDestinatarios(filtro, limit: limit);
  }

  @override
  Future<String> enviarImagem(File file) {
    return remoteDataSource.enviarImagem(file);
  }

  @override
  Future<Comunicado> criar({
    required String assunto,
    required String corpoHtml,
    bool? modoHtmlAvancado,
    required FiltroDestinatarioComunicado filtro,
  }) {
    return remoteDataSource.criar(
      assunto: assunto,
      corpoHtml: corpoHtml,
      modoHtmlAvancado: modoHtmlAvancado,
      filtro: filtro,
    );
  }

  @override
  Future<({List<Comunicado> items, int total})> listarComunicados({
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) {
    return remoteDataSource.listarComunicados(
      status: status,
      pagina: pagina,
      itemsPorPagina: itemsPorPagina,
    );
  }

  @override
  Future<Comunicado> buscarComunicado(int id) {
    return remoteDataSource.buscarComunicado(id);
  }

  @override
  Future<({List<ComunicadoDestinatario> items, int total})>
  listarDestinatarios(
    int comunicadoId, {
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) {
    return remoteDataSource.listarDestinatarios(
      comunicadoId,
      status: status,
      pagina: pagina,
      itemsPorPagina: itemsPorPagina,
    );
  }

  @override
  Future<ComunicadoDestinatario> reenviarDestinatario(
    int comunicadoId,
    int destinatarioId,
  ) {
    return remoteDataSource.reenviarDestinatario(comunicadoId, destinatarioId);
  }
}
