import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';
import 'package:precos/domain/data/remote/i_tabelas_de_preco_remote_data_source.dart';
import 'package:precos/domain/data/repositorios/i_tabelas_de_preco_repository.dart';
import 'package:precos/domain/models/tabela_de_preco.dart';

class TabelasDePrecoRepository implements ITabelasDePrecoRepository {
  final ITabelasDePrecoRemoteDataSource tabelasDePrecoRemoteDataSource;
  final ITabelasDePrecoLocalDataSource tabelasDePrecoLocalDataSource;
  final IPaginacaoDataSource paginacaoDataSource;

  TabelasDePrecoRepository({
    required this.tabelasDePrecoRemoteDataSource,
    required this.tabelasDePrecoLocalDataSource,
    required this.paginacaoDataSource,
  });

  @override
  Future<TabelaDePreco> atualizarTabelaDePreco({
    required int id,
    required String nome,
    double? terminador,
  }) {
    return tabelasDePrecoRemoteDataSource.atualizarTabelaDePreco(
      id: id,
      nome: nome,
      terminador: terminador,
    );
  }

  @override
  Future<TabelaDePreco> criarTabelaDePreco({
    required String nome,
    double? terminador,
  }) {
    return tabelasDePrecoRemoteDataSource.createTabelaDePreco(
      nome: nome,
      terminador: terminador,
    );
  }

  @override
  Future<void> desativarTabelaDePreco(int id) {
    return tabelasDePrecoRemoteDataSource.desativarTabelaDePreco(id);
  }

  @override
  Future<TabelaDePreco?> obterTabelaDePreco(int id) {
    return tabelasDePrecoRemoteDataSource.fetchTabelaDePreco(id);
  }

  @override
  Future<List<TabelaDePreco>> obterTabelasDePreco({
    String? nome,
    bool? inativa,
  }) {
    return tabelasDePrecoRemoteDataSource.fetchTabelasDePreco(
      nome: nome,
      inativa: inativa,
    );
  }

  @override
  Stream<Paginacao<TabelaDePreco>> syncTabelas() async* {
    final paginacao = await paginacaoDataSource.buscarPaginacao(
      'tabelas_de_preco_sync',
    );
    final page = paginacao?.ended == true ? 0 : (paginacao?.paginaAtual ?? 0);

    final tabelas = await tabelasDePrecoRemoteDataSource.fetchTabelasDePreco();

    if (tabelas.isNotEmpty) {
      await tabelasDePrecoLocalDataSource.salvarTabelasDePreco(tabelas);
    }

    final tabelasPaginadas = Paginacao<TabelaDePreco>(
      key: 'tabelas_de_preco_sync',
      paginaAtual: page,
      totalPaginas: tabelas.isEmpty ? 0 : 1,
      itensPorPagina: tabelas.length,
      itensProcessadosNaPagina: tabelas.length,
      totalItens: tabelas.length,
      dataAtualizacao: DateTime.now(),
      ended: true,
      items: tabelas,
    );

    yield tabelasPaginadas;
    await paginacaoDataSource.salvarPaginacao(tabelasPaginadas);
  }
}
