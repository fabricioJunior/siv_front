import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';

class ResgatarPontos {
  final IPontosRepository _pontosRepository;

  ResgatarPontos({required IPontosRepository pontosRepository})
      : _pontosRepository = pontosRepository;

  Future<void> call({
    required int idPessoa,
    required int valor,
    required String descricao,
  }) async {
    await _pontosRepository.resgatar(
      idPessoa: idPessoa,
      quantidade: valor,
      descricao: descricao,
    );
  }
}
