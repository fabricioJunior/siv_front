import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class RomaneiosRepository implements IRomaneiosRepository {
  final IRomaneiosRemoteDataSource remoteDataSource;

  RomaneiosRepository({required this.remoteDataSource});

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
  Future<List<Romaneio>> recuperarRomaneios({int page = 1, int limit = 50}) {
    return remoteDataSource.recuperarRomaneios(page: page, limit: limit);
  }
}
