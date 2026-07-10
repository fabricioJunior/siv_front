import 'package:comercial/models.dart';

abstract class IConsignacoesRepository {
  Future<List<Consignacao>> buscarPorFiltro({
    List<int>? empresaIds,
    List<int>? pessoaIds,
    List<int>? funcionarioIds,
    List<SituacaoConsignacao>? situacoes,
    bool incluirItens = false,
  });

  Future<Consignacao> abrir({
    required int pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required int caixaAbertura,
    String? observacao,
  });

  Future<Consignacao> buscarPorId(int id, {bool incluirItens = false});

  Future<Consignacao> atualizar({
    required int id,
    int? funcionarioId,
    String? observacao,
  });

  Future<void> recalcular(int id);

  Future<void> fechar(int id);

  Future<void> cancelar({required int id, required String motivoCancelamento});
}
