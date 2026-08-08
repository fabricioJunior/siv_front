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
    List<int>? referenciaIds,
  });
  Future<Romaneio> recuperarRomaneio(int id);
  Future<Romaneio> criarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio);
  Future<Romaneio> atualizarObservacao(int id, String observacao);
  Future<Romaneio> atualizarVendedor(int id, int funcionarioId);
  Future<Romaneio> finalizarRomaneio(int id);
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
    double? desconto,
    double? valorTaxaEntrega,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    Map<String, dynamic>? cupom,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  });
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  });
}
