import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class RomaneiosRepository implements IRomaneiosRepository {
  final IRomaneiosRemoteDataSource remoteDataSource;
  final IReceberRomaneioNoCaixaRemoteDataSource caixasRemoteDataSource;

  RomaneiosRepository({
    required this.remoteDataSource,
    required this.caixasRemoteDataSource,
  });

  @override
  Future<void> adicionarItemRomaneio(int romaneioId, RomaneioItem item) {
    return remoteDataSource.adicionarItemRomaneio(romaneioId, item);
  }

  @override
  Future<Romaneio> atualizarObservacao(int id, String observacao) {
    return remoteDataSource.atualizarObservacao(id, observacao);
  }

  @override
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio) {
    return remoteDataSource.atualizarRomaneio(romaneio);
  }

  @override
  Future<Romaneio> criarRomaneio(Romaneio romaneio) {
    return remoteDataSource.criarRomaneio(romaneio);
  }

  @override
  Future<Romaneio> recuperarRomaneio(int id) {
    return remoteDataSource.recuperarRomaneio(id);
  }

  @override
  Future<List<RomaneioItem>> recuperarItensRomaneio(int romaneioId) {
    return remoteDataSource.recuperarItensRomaneio(romaneioId);
  }

  @override
  Future<List<Romaneio>> recuperarRomaneios({int page = 1, int limit = 50}) {
    return remoteDataSource.recuperarRomaneios(page: page, limit: limit);
  }

  @override
  Future<void> removerItemRomaneio(int romaneioId, RomaneioItem item) {
    return remoteDataSource.removerItemRomaneio(romaneioId, item);
  }

  @override
  Future<void> receberRomaneioNoCaixa({
    required int caixaId,
    required int romaneioId,
  }) {
    return caixasRemoteDataSource.receberRomaneio(
      caixaId: caixaId,
      romaneioId: romaneioId,
    );
  }
}
