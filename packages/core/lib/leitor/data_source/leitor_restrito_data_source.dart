import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

/// Decora um [ILeitorDataDatasource] existente restringindo a bipagem por
/// código a um conjunto fixo de produtos (ex: os itens de um romaneio
/// específico, como na devolução) -- produto fora do conjunto permitido
/// vira "não encontrado", sem duplicar a lógica de busca em si.
class LeitorRestritoDataSource implements ILeitorDataDatasource {
  final ILeitorDataDatasource origem;
  final Set<int> produtosPermitidos;

  LeitorRestritoDataSource({
    required this.origem,
    required this.produtosPermitidos,
  });

  @override
  Future<LeitorData?> getData(
    String codigo, {
    int? tabelaDePrecoId,
  }) async {
    final data = await origem.getData(codigo, tabelaDePrecoId: tabelaDePrecoId);
    if (data == null || !produtosPermitidos.contains(data.id)) {
      return null;
    }
    return data;
  }

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async {
    if (!produtosPermitidos.contains(produtoId)) {
      return null;
    }
    return origem.getDataPorProdutoId(produtoId, tabelaDePrecoId: tabelaDePrecoId);
  }
}
