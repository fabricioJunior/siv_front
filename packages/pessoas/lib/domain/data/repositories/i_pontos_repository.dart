import '../../models/ponto.dart';

abstract class IPontosRepository {
  Future<Ponto> novoPonto({
    required int idPessoa,
    required int valor,
    required String descricao,
    required DateTime validade,
  });

  Future<List<Ponto>> getPontos({
    required int idPessoa,
  });

  Future<Ponto> resgatar({
    required int idPessoa,
    required int quantidade,
    required String descricao,
  });

  Future<void> cancelarPonto({
    required int idPessoa,
    required int idPonto,
  });
}
