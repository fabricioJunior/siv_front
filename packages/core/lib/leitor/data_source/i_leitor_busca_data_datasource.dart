import 'package:core/leitor/leitor_data.dart';

abstract class ILeitorBuscaDataDatasource {
  /// Busca produtos por texto, opcionalmente filtrando por tamanho e cor.
  /// Retorna a lista de variantes (SKUs) que correspondem à busca.
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,

    /// Restringe a busca a estes produtos (ex.: itens do romaneio na devolução). Precisa ser
    /// aplicado DENTRO da busca, antes do limite de resultados: filtrar só depois pode descartar
    /// tudo quando o termo bate em mais SKUs do que o limite.
    Set<int>? somenteProdutoIds,
  });
}
