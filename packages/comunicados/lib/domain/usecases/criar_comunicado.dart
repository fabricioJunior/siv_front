import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class CriarComunicado {
  final IComunicadoRepository repository;

  CriarComunicado({required this.repository});

  Future<Comunicado> call({
    required String assunto,
    required String corpoHtml,
    bool? modoHtmlAvancado,
    required FiltroDestinatarioComunicado filtro,
  }) {
    return repository.criar(
      assunto: assunto,
      corpoHtml: corpoHtml,
      modoHtmlAvancado: modoHtmlAvancado,
      filtro: filtro,
    );
  }
}
