import 'package:core/paginacao.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';
import 'package:precos/domain/data/remote/i_precos_de_referencias_remote_data_source.dart';
import 'package:precos/domain/data/repositorios/i_precos_de_referencias_repository.dart';
import 'package:precos/models.dart';

class PrecosDeReferenciasRepository implements IPrecosDeReferenciasRepository {
  final IPrecosDeReferenciasRemoteDataSource
  precosDeReferenciasRemoteDataSource;
  final IPaginacaoDataSource paginacaoDataSource;
  final ITabelasDePrecoLocalDataSource tabelasDePrecoLocalDataSource;
  final IPrecosDeReferenciasLocalDataSource precosDeReferenciasLocalDataSource;

  PrecosDeReferenciasRepository({
    required this.precosDeReferenciasRemoteDataSource,
    required this.paginacaoDataSource,
    required this.tabelasDePrecoLocalDataSource,
    required this.precosDeReferenciasLocalDataSource,
  });

  @override
  Future<PrecoDaReferencia> atualizarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) {
    return precosDeReferenciasRemoteDataSource.criarPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
    );
  }

  @override
  Future<PrecoDaReferencia> criarPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) {
    return precosDeReferenciasRemoteDataSource.criarPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
    );
  }

  @override
  Future<PrecoDaReferencia> obterPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return precosDeReferenciasRemoteDataSource.obterPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }

  @override
  Future<List<PrecoDaReferencia>> obterPrecosDasReferencias({
    required int tabelaDePrecoId,
  }) {
    return precosDeReferenciasRemoteDataSource.obterPrecosDasReferencias(
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }

  @override
  Future<void> removerPrecoDaReferencia({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return precosDeReferenciasRemoteDataSource.removerPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }

  @override
  Stream<Paginacao<PrecoDaReferencia>> syncPrecosDasReferencias() async* {
    final paginacao = await paginacaoDataSource.buscarPaginacao(
      'precos_das_referencias_sync',
    );
    final tabelas = await tabelasDePrecoLocalDataSource.obterTabelasDePreco();
    final paginaInicial = paginacao?.ended == true
        ? 0
        : (paginacao?.paginaAtual ?? 0);

    if (tabelas.isEmpty || paginaInicial >= tabelas.length) {
      final paginacaoFinal = Paginacao<PrecoDaReferencia>(
        paginaAtual: 0,
        totalPaginas: tabelas.length,
        itensPorPagina: 0,
        itensProcessadosNaPagina: 0,
        totalItens: 0,
        key: 'precos_das_referencias_sync',
        dataAtualizacao: DateTime.now(),
        ended: true,
      );

      yield paginacaoFinal;
      await paginacaoDataSource.salvarPaginacao(paginacaoFinal);
      return;
    }

    var totalItensSincronizados = 0;

    for (var index = paginaInicial; index < tabelas.length; index++) {
      final tabelaId = tabelas[index].id;
      if (tabelaId == null) {
        continue;
      }

      final precos = await precosDeReferenciasRemoteDataSource
          .obterPrecosDasReferencias(tabelaDePrecoId: tabelaId);

      await precosDeReferenciasLocalDataSource.salvarPrecosDasReferencias(
        precos,
      );
      totalItensSincronizados += precos.length;

      final paginacaoAtual = Paginacao<PrecoDaReferencia>(
        paginaAtual: index,
        totalPaginas: tabelas.length,
        itensPorPagina: precos.length,
        itensProcessadosNaPagina: precos.length,
        totalItens: totalItensSincronizados,
        key: 'precos_das_referencias_sync',
        dataAtualizacao: DateTime.now(),
        ended: index == tabelas.length - 1,
        items: precos,
      );

      yield paginacaoAtual;
      await paginacaoDataSource.salvarPaginacao(paginacaoAtual);
    }
  }
}
