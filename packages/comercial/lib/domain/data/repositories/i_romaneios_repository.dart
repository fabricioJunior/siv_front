import 'package:comercial/models.dart';

abstract class IRomaneiosRepository {
  Future<List<Romaneio>> recuperarRomaneios({
    int page = 1,
    int limit = 50,
    String? searchTerm,
    int? caixaId,
    DateTime? dataHoraInicial,
    DateTime? dataHoraFinal,
    List<TipoOperacao>? operacoes,
  });
  Future<Romaneio> recuperarRomaneio(int id);
  Future<Romaneio> criarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarObservacao(int id, String observacao);
  Future<Romaneio> atualizarVendedor(int id, int funcionarioId);
  Future<List<RomaneioItem>> recuperarItensRomaneio(int romaneioId);
  Future<List<RomaneioItemDevolvido>> recuperarItensDevolvidosRomaneio(
    int romaneioId,
  );
  Future<void> adicionarItemRomaneio(int romaneioId, RomaneioItem item);
  Future<void> removerItemRomaneio(int romaneioId, RomaneioItem item);
  Future<void> receberRomaneioNoCaixa({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
  });
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  });
}
