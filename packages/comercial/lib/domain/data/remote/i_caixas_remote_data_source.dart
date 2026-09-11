import 'package:comercial/models.dart';

abstract class IReceberRomaneioNoCaixaRemoteDataSource {
  Future<void> receberRomaneio({
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
}

// Cria o romaneio, adiciona os itens e recebe no caixa em 1 request só -- substitui o fluxo de
// criar + N itens + receber (3+ chamadas) só pra operação de venda (romaneio novo do zero).
abstract class ICriarVendaCompletaRemoteDataSource {
  Future<Romaneio> criarVendaCompleta({
    required int caixaId,
    int? pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required List<RomaneioItem> itens,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    Map<String, dynamic>? cupom,
    double? valorTaxaEntrega,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  });
}

abstract class ICorrigirFormaDePagamentoRemoteDataSource {
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  });
}
