import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class ReceberRomaneioNoCaixa {
  final IRomaneiosRepository _repository;

  ReceberRomaneioNoCaixa({required IRomaneiosRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    double? desconto,
    double? valorTaxaEntrega,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
  }) {
    return _repository.receberRomaneioNoCaixa(
      caixaId: caixaId,
      romaneioId: romaneioId,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
      desconto: desconto,
      valorTaxaEntrega: valorTaxaEntrega,
      descontosItens: descontosItens,
      incluirCpfNaNota: incluirCpfNaNota,
      cpfNaNota: cpfNaNota,
      pontuarFidelidade: pontuarFidelidade,
    );
  }
}
