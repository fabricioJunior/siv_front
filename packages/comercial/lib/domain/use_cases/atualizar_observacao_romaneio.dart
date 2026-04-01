import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class AtualizarObservacaoRomaneio {
  final IRomaneiosRepository _repository;

  AtualizarObservacaoRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(int id, String observacao) {
    return _repository.atualizarObservacao(id, observacao);
  }
}
