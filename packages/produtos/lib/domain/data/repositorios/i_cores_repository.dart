import 'package:produtos/models.dart';

abstract class ICoresRepository {
  Future<Cor> criarCor(String nome);
  Future<List<Cor>> obterCores({String? nome, bool? inativo});
  Future<Cor?> obterCor(int id);
  Future<void> desativarCor(int id);

  Future<Cor> atualizarCor(int id, String nome);
}
