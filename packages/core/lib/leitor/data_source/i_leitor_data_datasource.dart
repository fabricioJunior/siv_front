import 'package:core/leitor/leitor_data.dart';

abstract class ILeitorDataDatasource {
  Future<LeitorData?> getData(
    String codigo, {
    int? tabelaDePrecoId,
  });

  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  });
}
