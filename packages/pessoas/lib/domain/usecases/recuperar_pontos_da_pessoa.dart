import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarPontosDaPessoa {
  final IPontosRepository _pontosRepository;

  RecuperarPontosDaPessoa({required IPontosRepository pontosRepository})
      : _pontosRepository = pontosRepository;

  Future<List<Ponto>> call({
    required int idPessoa,
  }) async {
    return _pontosRepository.getPontos(idPessoa: idPessoa);
  }
}
