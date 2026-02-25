import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarPontosDaPessoa {
  final IPontosRepository _pontosRepository;

  RecuperarPontosDaPessoa({required IPontosRepository pontosRepository})
      : _pontosRepository = pontosRepository;

  Future<List<Ponto>> call({
    required int idPessoa,
  }) async {
    final pontos = await _pontosRepository.getPontos(idPessoa: idPessoa);

    final pontosFiltrados = pontos.where((ponto) => !ponto.cancelado).toList();

    pontosFiltrados.sort((a, b) {
      final dataA = a.dtCriacao;
      final dataB = b.dtCriacao;

      if (dataA == null && dataB == null) return 0;
      if (dataA == null) return 1;
      if (dataB == null) return -1;

      return dataB.compareTo(dataA);
    });

    return pontosFiltrados;
  }
}
