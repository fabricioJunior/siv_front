import 'package:precos/domain/data/remote/i_precos_de_referencias_remote_data_source.dart';
import 'package:precos/domain/data/repositorios/i_precos_de_referencias_repository.dart';
import 'package:precos/models.dart';

class PrecosDeReferenciasRepository implements IPrecosDeReferenciasRepository {
  final IPrecosDeReferenciasRemoteDataSource
  precosDeReferenciasRemoteDataSource;

  PrecosDeReferenciasRepository({
    required this.precosDeReferenciasRemoteDataSource,
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
}
