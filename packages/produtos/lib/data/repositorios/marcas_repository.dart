import 'package:produtos/domain/data/remote/i_marcas_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_marcas_repository.dart';
import 'package:produtos/domain/models/marca.dart';

class MarcasRepository implements IMarcasRepository {
  final IMarcasRemoteDataSource marcasRemoteDataSource;

  MarcasRepository({required this.marcasRemoteDataSource});

  @override
  Future<Marca> atualizarMarca(int id, String nome) {
    return marcasRemoteDataSource.atualizarMarca(id, nome);
  }

  @override
  Future<Marca> criarMarca(String nome) {
    return marcasRemoteDataSource.createMarca(nome);
  }

  @override
  Future<void> desativarMarca(int id) {
    return marcasRemoteDataSource.desativarMarca(id);
  }

  @override
  Future<Marca?> obterMarca(int id) {
    return marcasRemoteDataSource.fetchMarca(id);
  }

  @override
  Future<List<Marca>> obterMarcas({String? nome, bool? inativa}) {
    return marcasRemoteDataSource.fetchMarcas(nome: nome, inativa: inativa);
  }
}
