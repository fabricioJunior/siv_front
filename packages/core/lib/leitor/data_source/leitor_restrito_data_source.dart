import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

/// Decora um [ILeitorDataDatasource] existente restringindo a bipagem por
/// código a um conjunto fixo de produtos com saldo próprio (ex: os itens de
/// um romaneio específico, como na devolução) -- produto fora do conjunto
/// permitido vira "não encontrado" e o campo [LeitorData.quantidade] passa a
/// refletir o saldo informado (ex: saldo disponível para devolução no
/// romaneio), em vez do estoque geral da loja retornado pela origem.
class LeitorRestritoDataSource implements ILeitorDataDatasource {
  final ILeitorDataDatasource origem;
  final Map<int, double> saldosDisponiveis;

  LeitorRestritoDataSource({
    required this.origem,
    required this.saldosDisponiveis,
  });

  @override
  Future<LeitorData?> getData(
    String codigo, {
    int? tabelaDePrecoId,
  }) async {
    final data = await origem.getData(codigo, tabelaDePrecoId: tabelaDePrecoId);
    return _restringir(data);
  }

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) async {
    if (!saldosDisponiveis.containsKey(produtoId)) {
      return null;
    }
    final data = await origem.getDataPorProdutoId(
      produtoId,
      tabelaDePrecoId: tabelaDePrecoId,
    );
    return _restringir(data);
  }

  LeitorData? _restringir(LeitorData? data) {
    if (data == null) return null;
    final saldo = saldosDisponiveis[data.id];
    if (saldo == null) return null;
    return _LeitorDataComSaldo(origem: data, saldo: saldo.toInt());
  }
}

class _LeitorDataComSaldo implements LeitorData {
  final LeitorData origem;
  final int saldo;

  _LeitorDataComSaldo({required this.origem, required this.saldo});

  @override
  String get codigoDeBarras => origem.codigoDeBarras;

  @override
  String get descricao => origem.descricao;

  @override
  int get quantidade => saldo;

  @override
  int get idReferencia => origem.idReferencia;

  @override
  String get tamanho => origem.tamanho;

  @override
  String get cor => origem.cor;

  @override
  double? get valor => origem.valor;

  @override
  int get id => origem.id;

  @override
  Map<String, dynamic> get dados => origem.dados;
}
