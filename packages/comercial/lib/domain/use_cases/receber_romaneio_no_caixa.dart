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
  }) {
    return _repository.receberRomaneioNoCaixa(
      caixaId: caixaId,
      romaneioId: romaneioId,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
    );
  }
}
