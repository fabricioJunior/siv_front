import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';

class ReenviarDestinatarioComunicado {
  final IComunicadoRepository repository;

  ReenviarDestinatarioComunicado({required this.repository});

  Future<ComunicadoDestinatario> call({
    required int comunicadoId,
    required int destinatarioId,
  }) {
    return repository.reenviarDestinatario(comunicadoId, destinatarioId);
  }
}
