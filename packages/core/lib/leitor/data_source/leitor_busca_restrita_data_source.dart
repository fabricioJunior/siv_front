import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

/// Decora um [ILeitorBuscaDataDatasource] existente restringindo os
/// resultados da busca manual a um conjunto fixo de produtos com saldo
/// próprio (ex: os itens de um romaneio específico, como na devolução) --
/// sem duplicar a lógica de busca em si, só filtrando o que já veio da fonte
/// de dados original e sobrescrevendo [LeitorData.quantidade] com o saldo
/// informado (ex: saldo disponível para devolução no romaneio), em vez do
/// estoque geral da loja.
class LeitorBuscaRestritaDataSource implements ILeitorBuscaDataDatasource {
  final ILeitorBuscaDataDatasource origem;
  final Map<int, double> saldosDisponiveis;

  LeitorBuscaRestritaDataSource({
    required this.origem,
    required this.saldosDisponiveis,
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
        .where((item) => saldosDisponiveis.containsKey(item.id))
        .map(
          (item) => _LeitorDataComSaldo(
            origem: item,
            saldo: saldosDisponiveis[item.id]!.toInt(),
          ),
        )
        .toList();
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
