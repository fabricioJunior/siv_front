import 'package:produtos/models.dart';

abstract class ICoresRemoteDataSource {
  Future<Cor> createCor(String nome);
  Future<List<Cor>> fetchCores({String? nome, bool? inativo});
  Future<Cor?> fetchCor(int id);
  Future<void> desativarCor(int id);
  Future<Cor> atualizarCor(int id, String nome);
}
