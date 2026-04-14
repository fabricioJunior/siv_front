import 'package:financeiro/domain/data/repositories/i_caixa_repository.dart';
import 'package:financeiro/domain/models/extrato_caixa.dart';

class BuscarExtratoCaixaPorDocumento {
  final ICaixaRepository _repository;

  BuscarExtratoCaixaPorDocumento({required ICaixaRepository repository})
      : _repository = repository;

  Future<List<ExtratoCaixa>> call({
    required int caixaId,
    required String documento,
  }) {
    return _repository.buscarExtratoCaixaPorDocumento(
      caixaId: caixaId,
      documento: documento,
    );
  }
}
