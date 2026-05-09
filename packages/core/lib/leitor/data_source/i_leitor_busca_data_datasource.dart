import 'package:core/leitor/leitor_data.dart';

abstract class ILeitorBuscaDataDatasource {
  /// Busca produtos por texto, opcionalmente filtrando por tamanho e cor.
  /// Retorna a lista de variantes (SKUs) que correspondem à busca.
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
  });
}
