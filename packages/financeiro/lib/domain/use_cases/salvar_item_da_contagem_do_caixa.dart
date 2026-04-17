import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';

class SalvarItemDaContagemDoCaixa {
  final IContagemDoCaixaRepository _repository;

  SalvarItemDaContagemDoCaixa({required IContagemDoCaixaRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) {
    return _repository.salvarItemDaContagemDoCaixa(
      caixaId: caixaId,
      contagemDoCaixa: contagemDoCaixa,
    );
  }
}
