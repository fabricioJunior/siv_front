import 'package:produtos/models.dart';

abstract class IMarcasRemoteDataSource {
  Future<Marca> createMarca(String nome);
  Future<List<Marca>> fetchMarcas({String? nome, bool? inativa});
  Future<Marca?> fetchMarca(int id);
  Future<void> desativarMarca(int id);
  Future<Marca> atualizarMarca(int id, String nome);
}
