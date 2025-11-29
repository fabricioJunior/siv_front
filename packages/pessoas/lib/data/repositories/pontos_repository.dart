import 'package:pessoas/domain/data/data_sourcers/remote/i_pontos_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_pontos_repository.dart';
import 'package:pessoas/domain/models/ponto.dart';

class PontosRepository implements IPontosRepository {
  final IPontosRemoteDataSource _pontosRemoteDataSource;

  PontosRepository({required IPontosRemoteDataSource pontosRemoteDataSource})
      : _pontosRemoteDataSource = pontosRemoteDataSource;

  @override
  Future<void> cancelarPonto({required int idPessoa, required int idPonto}) {
    return _pontosRemoteDataSource.excluirPonto(
      idPessoa: idPessoa,
      idPonto: idPonto,
    );
  }

  @override
  Future<List<Ponto>> getPontos({required int idPessoa}) {
    return _pontosRemoteDataSource.getPontos(idPessoa: idPessoa);
  }

  @override
  Future<Ponto> novoPonto({
    required int idPessoa,
    required int valor,
    required String descricao,
    required DateTime validade,
  }) {
    return _pontosRemoteDataSource.postPonto(
      valor: valor,
      validade: validade,
      descricao: descricao,
      idPessoa: idPessoa,
    );
  }

  @override
  Future<Ponto> resgatar({
    required int idPessoa,
    required int quantidade,
    required String descricao,
  }) {
    return _pontosRemoteDataSource.regatarPontos(
      idPessoa: idPessoa,
      quantidade: quantidade,
      descricao: descricao,
    );
  }
}
