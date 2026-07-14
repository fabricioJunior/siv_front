import 'package:comercial/models.dart';

abstract class IReceberRomaneioNoCaixaRemoteDataSource {
  Future<void> receberRomaneio({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    double? desconto,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
  });
}

abstract class ICorrigirFormaDePagamentoRemoteDataSource {
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  });
}
