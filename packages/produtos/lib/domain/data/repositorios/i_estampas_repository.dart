import '../../../models.dart';

abstract class IEstampasRepository {
  Future<Estampa> criarEstampa(String nome);
  Future<List<Estampa>> obterEstampas({String? nome, bool? inativo});
  Future<Estampa?> obterEstampa(int id);
  Future<void> desativarEstampa(int id);

  Future<Estampa> atualizarEstampa(int id, String nome);
}
