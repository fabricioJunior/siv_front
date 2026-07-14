import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

/// Decora um [ILeitorBuscaDataDatasource] existente restringindo os
/// resultados da busca manual a um conjunto fixo de produtos (ex: os itens
/// de um romaneio específico, como na devolução) -- sem duplicar a lógica
/// de busca em si, só filtrando o que já veio da fonte de dados original.
class LeitorBuscaRestritaDataSource implements ILeitorBuscaDataDatasource {
  final ILeitorBuscaDataDatasource origem;
  final Set<int> produtosPermitidos;

  LeitorBuscaRestritaDataSource({
    required this.origem,
    required this.produtosPermitidos,
  });

  @override
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
  }) async {
    final resultado = await origem.buscarPorTexto(
      texto,
      tamanho: tamanho,
      cor: cor,
      tabelaDePrecoId: tabelaDePrecoId,
    );

    return resultado
        .where((item) => produtosPermitidos.contains(item.id))
        .toList();
  }
}
