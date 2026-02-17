import 'package:produtos/domain/data/remote/i_tamanhos_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_tamanhos_repository.dart';
import 'package:produtos/domain/models/tamanho.dart';

class TamanhosRepository implements ITamanhosRepository {
  final ITamanhosRemoteDataSource tamanhosRemoteDataSource;

  TamanhosRepository({required this.tamanhosRemoteDataSource});

  @override
  Future<Tamanho> atualizarTamanho(int id, String nome) {
    return tamanhosRemoteDataSource.atualizarTamanho(id, nome);
  }

  @override
  Future<Tamanho> criarTamanho(String nome) {
    return tamanhosRemoteDataSource.createTamanho(nome);
  }

  @override
  Future<void> desativarTamanho(int id) {
    return tamanhosRemoteDataSource.desativarTamanho(id);
  }

  @override
  Future<Tamanho?> obterTamanho(int id) {
    return tamanhosRemoteDataSource.fetchTamanho(id);
  }

  @override
  Future<List<Tamanho>> obterTamanhos({String? nome, bool? inativo}) {
    return tamanhosRemoteDataSource.fetchTamanhos(nome: nome, inativo: inativo);
  }
}
