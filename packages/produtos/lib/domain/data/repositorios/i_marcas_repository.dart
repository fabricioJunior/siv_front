import 'package:produtos/models.dart';

abstract class IMarcasRepository {
  Future<Marca> criarMarca(String nome);
  Future<List<Marca>> obterMarcas({String? nome, bool? inativa});
  Future<Marca?> obterMarca(int id);
  Future<void> desativarMarca(int id);
  Future<Marca> atualizarMarca(int id, String nome);
}
