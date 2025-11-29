import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';

class CancelarPonto {
  final IPontosRepository _pontosRepository;

  CancelarPonto({required IPontosRepository pontosRepository})
      : _pontosRepository = pontosRepository;

  Future<void> call({required int idPessoa, required int idPonto}) {
    return _pontosRepository.cancelarPonto(
        idPessoa: idPessoa, idPonto: idPonto);
  }
}
