import 'package:produtos/domain/data/remote/i_cores_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_cores_repository.dart';
import 'package:produtos/domain/models/cor.dart';

class CoresRepository implements ICoresRepository {
  final ICoresRemoteDataSource coresRemoteDataSource;

  CoresRepository({required this.coresRemoteDataSource});

  @override
  Future<Cor> atualizarCor(int id, String nome) {
    return coresRemoteDataSource.atualizarCor(id, nome);
  }

  @override
  Future<Cor> criarCor(String nome) {
    return coresRemoteDataSource.createCor(nome);
  }

  @override
  Future<void> desativarCor(int id) {
    return coresRemoteDataSource.desativarCor(id);
  }

  @override
  Future<Cor?> obterCor(int id) {
    return coresRemoteDataSource.fetchCor(id);
  }

  @override
  Future<List<Cor>> obterCores({String? nome, bool? inativo}) {
    return coresRemoteDataSource.fetchCores(nome: nome, inativo: inativo);
  }
}
