import '../../models/orcamento_local.dart';

abstract class IOrcamentoRepository {
  Future<OrcamentoLocal> salvar(OrcamentoLocal orcamento);

  Future<List<OrcamentoLocal>> listar();

  Future<OrcamentoLocal?> recuperar(String hash);

  Future<void> excluir(String hash);

  Future<int?> obterEstoqueDisponivel({
    required int produtoId,
    int? tabelaPrecoId,
  });
}
