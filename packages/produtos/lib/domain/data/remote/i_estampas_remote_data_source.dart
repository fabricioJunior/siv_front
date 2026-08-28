import '../../../models.dart';

abstract class IEstampasRemoteDataSource {
  Future<List<Estampa>> fetchEstampas({String? nome, bool? inativo});

  Future<Estampa> atualizarEstampa(int id, String nome);

  Future<Estampa> fetchEstampa(int id);

  Future<Estampa> createEstampa(String nome);

  Future<void> desativarEstampa(int id);
}
