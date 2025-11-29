import 'package:pessoas/models.dart';

abstract class IPontosRemoteDataSource {
  Future<Ponto> postPonto({
    required int valor,
    required DateTime validade,
    required String descricao,
    required int idPessoa,
  });

  Future<List<Ponto>> getPontos({
    required int idPessoa,
  });

  Future<Ponto> regatarPontos({
    required int idPessoa,
    required int quantidade,
    required String descricao,
  });

  Future<void> excluirPonto({
    required int idPessoa,
    required int idPonto,
  });
}
