import 'package:comercial/models.dart';

abstract class IRomaneiosRepository {
  Future<List<Romaneio>> recuperarRomaneios({int page = 1, int limit = 50});
  Future<Romaneio> recuperarRomaneio(int id);
  Future<Romaneio> criarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarObservacao(int id, String observacao);
  Future<List<RomaneioItem>> recuperarItensRomaneio(int romaneioId);
  Future<void> adicionarItemRomaneio(int romaneioId, RomaneioItem item);
  Future<void> removerItemRomaneio(int romaneioId, RomaneioItem item);
  Future<void> receberRomaneioNoCaixa({
    required int caixaId,
    required int romaneioId,
  });
}
