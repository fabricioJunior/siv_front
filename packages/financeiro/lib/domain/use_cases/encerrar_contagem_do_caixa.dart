import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';

class EncerrarContagemDoCaixa {
  final IContagemDoCaixaRepository _repository;

  EncerrarContagemDoCaixa({required IContagemDoCaixaRepository repository})
      : _repository = repository;

  Future<void> call({required int caixaId}) {
    return _repository.encerrarContagemDoCaixa(caixaId: caixaId);
  }
}
