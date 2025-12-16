import '../../../models.dart';

abstract class ITamanhosRepository {
  Future<Tamanho> criarTamanho(String nome);
  Future<List<Tamanho>> obterTamanhos({String? nome, bool? inativo});
  Future<Tamanho?> obterTamanho(int id);
  Future<void> desativarTamanho(int id);
}
