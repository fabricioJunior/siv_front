import 'package:produtos/domain/data/remote/i_estampas_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_estampas_repository.dart';
import 'package:produtos/domain/models/estampa.dart';

class EstampasRepository implements IEstampasRepository {
  final IEstampasRemoteDataSource estampasRemoteDataSource;

  EstampasRepository({required this.estampasRemoteDataSource});

  @override
  Future<Estampa> atualizarEstampa(int id, String nome) {
    return estampasRemoteDataSource.atualizarEstampa(id, nome);
  }

  @override
  Future<Estampa> criarEstampa(String nome) {
    return estampasRemoteDataSource.createEstampa(nome);
  }

  @override
  Future<void> desativarEstampa(int id) {
    return estampasRemoteDataSource.desativarEstampa(id);
  }

  @override
  Future<Estampa?> obterEstampa(int id) {
    return estampasRemoteDataSource.fetchEstampa(id);
  }

  @override
  Future<List<Estampa>> obterEstampas({String? nome, bool? inativo}) {
    return estampasRemoteDataSource.fetchEstampas(nome: nome, inativo: inativo);
  }
}
