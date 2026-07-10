import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class ConsignacoesRepository implements IConsignacoesRepository {
  final IConsignacoesRemoteDataSource remoteDataSource;

  ConsignacoesRepository({required this.remoteDataSource});

  @override
  Future<Consignacao> abrir({
    required int pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required int caixaAbertura,
    String? observacao,
  }) {
    return remoteDataSource.abrir(
      pessoaId: pessoaId,
      funcionarioId: funcionarioId,
      tabelaPrecoId: tabelaPrecoId,
      caixaAbertura: caixaAbertura,
      observacao: observacao,
    );
  }

  @override
  Future<Consignacao> atualizar({
    required int id,
    int? funcionarioId,
    String? observacao,
  }) {
    return remoteDataSource.atualizar(
      id: id,
      funcionarioId: funcionarioId,
      observacao: observacao,
    );
  }

  @override
  Future<List<Consignacao>> buscarPorFiltro({
    List<int>? empresaIds,
    List<int>? pessoaIds,
    List<int>? funcionarioIds,
    List<SituacaoConsignacao>? situacoes,
    bool incluirItens = false,
  }) {
    return remoteDataSource.buscarPorFiltro(
      empresaIds: empresaIds,
      pessoaIds: pessoaIds,
      funcionarioIds: funcionarioIds,
      situacoes: situacoes,
      incluirItens: incluirItens,
    );
  }

  @override
  Future<Consignacao> buscarPorId(int id, {bool incluirItens = false}) {
    return remoteDataSource.buscarPorId(id, incluirItens: incluirItens);
  }

  @override
  Future<void> cancelar({required int id, required String motivoCancelamento}) {
    return remoteDataSource.cancelar(
      id: id,
      motivoCancelamento: motivoCancelamento,
    );
  }

  @override
  Future<void> fechar(int id) {
    return remoteDataSource.fechar(id);
  }

  @override
  Future<void> recalcular(int id) {
    return remoteDataSource.recalcular(id);
  }
}
