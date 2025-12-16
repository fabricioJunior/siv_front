import '../../../models.dart';

abstract class ITamanhosRemoteDataSource {
  Future<List<Tamanho>> fetchTamanhos({
    String? nome,
    bool? inativo,
  });

  Future<Tamanho> fetchTamanho(int id);

  Future<Tamanho> createTamanho(String nome);

  Future<void> desativarTamanho(int id);
}
