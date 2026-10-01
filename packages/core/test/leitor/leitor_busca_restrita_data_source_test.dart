import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/data_source/leitor_busca_restrita_data_source.dart';
import 'package:core/leitor/leitor_data.dart';
import 'package:flutter_test/flutter_test.dart';

class _LeitorDataFake implements LeitorData {
  @override
  final int id;
  _LeitorDataFake(this.id);

  @override
  String get codigoDeBarras => '';
  @override
  String get descricao => 'BLUSA $id';
  @override
  int get quantidade => 0;
  @override
  int get idReferencia => id;
  @override
  String get tamanho => 'UN';
  @override
  String get cor => 'AZUL';
  @override
  double? get valor => null;
  @override
  Map<String, dynamic> get dados => const {};
}

class _OrigemFake implements ILeitorBuscaDataDatasource {
  Set<int>? idsRecebidos;

  @override
  Future<List<LeitorData>> buscarPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
    int? tabelaDePrecoId,
    Set<int>? somenteProdutoIds,
  }) async {
    idsRecebidos = somenteProdutoIds;
    return [_LeitorDataFake(1), _LeitorDataFake(2)];
  }
}

void main() {
  test('repassa os produtos permitidos à busca de origem e devolve só eles, com o saldo do romaneio',
      () async {
    final origem = _OrigemFake();
    final restrita = LeitorBuscaRestritaDataSource(
      origem: origem,
      saldosDisponiveis: {2: 3},
    );

    final resultado = await restrita.buscarPorTexto('blusa');

    expect(origem.idsRecebidos, {2});
    expect(resultado.map((r) => r.id), [2]);
    expect(resultado.first.quantidade, 3);
  });
}
