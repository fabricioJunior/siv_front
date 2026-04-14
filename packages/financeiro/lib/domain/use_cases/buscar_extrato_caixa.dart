import 'package:financeiro/domain/data/repositories/i_caixa_repository.dart';
import 'package:financeiro/domain/models/extrato_caixa.dart';

class BuscarExtratoCaixa {
  final ICaixaRepository _repository;

  BuscarExtratoCaixa({required ICaixaRepository repository})
      : _repository = repository;

  Future<List<ExtratoCaixa>> call({required int caixaId}) {
    return _repository.buscarExtratoCaixa(caixaId: caixaId);
  }
}
