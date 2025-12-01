import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/models.dart';

class CriarPontos {
  final IPontosRepository _pontosRepository;

  CriarPontos({required IPontosRepository pontosRepository})
      : _pontosRepository = pontosRepository;

  Future<Ponto> call({
    required int idPessoa,
    required int valor,
    required String descricao,
  }) {
    var validade = DateTime.now().add(
      Duration(days: 365),
    );
    return _pontosRepository.novoPonto(
      idPessoa: idPessoa,
      valor: valor,
      descricao: descricao,
      validade: validade,
    );
  }
}
