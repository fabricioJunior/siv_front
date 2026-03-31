import 'package:comercial/models.dart';

abstract class IRomaneiosRepository {
  Future<List<Romaneio>> recuperarRomaneios({int page = 1, int limit = 50});
  Future<Romaneio> recuperarRomaneio(int id);
  Future<Romaneio> criarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarObservacao(int id, String observacao);
}
