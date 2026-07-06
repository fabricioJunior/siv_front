import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';

class CancelarContagemDoCaixa {
  final IContagemDoCaixaRepository _repository;

  CancelarContagemDoCaixa({required IContagemDoCaixaRepository repository})
      : _repository = repository;

  Future<void> call({required int caixaId}) {
    return _repository.cancelarContagemDoCaixa(caixaId: caixaId);
  }
}
