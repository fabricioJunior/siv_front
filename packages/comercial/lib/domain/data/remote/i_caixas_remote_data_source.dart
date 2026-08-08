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

abstract class ICorrigirFormaDePagamentoRemoteDataSource {
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  });
}
